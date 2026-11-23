require "rails_helper"

RSpec.describe "Redirect after sign in from signed out state", :js do
  let(:user) { create(:user) }
  let!(:sealed_sake) { create(:sake, bottle_level: "sealed") }

  # Turbo は hover から 100ms 後に先読みを始める。
  # 先読みのリクエストを待つ書き方にしないのは、ログアウト中は先読みが飛ばない実装でも通すため。
  def hover_and_wait(element)
    element.hover
    sleep(0.2)
  end

  def hover_and_click(element)
    hover_and_wait(element)
    element.click
  end

  def open_header_menu
    find(".navbar-toggler").click
  end

  # ヘッダーのメニューを開いてから呼ぶ
  def sign_in_from_header
    within(:test_id, "navigation_list") { click_link("sign_in") }
    wait_for_page(new_user_session_path)
    signin_process_on_signin_page(user)
  end

  shared_examples "redirects to the requested page after sign in" do
    it "redirects to sign in page with alert", :aggregate_failures do
      expect(page).to have_current_path(new_user_session_path)
      expect(find(:test_id, "flash_message")).to have_text(I18n.t("devise.failure.unauthenticated"))
    end

    it "redirects to the requested page after sign in" do
      signin_process_on_signin_page(user)
      expect(page).to have_current_path(requested_path)
    end
  end

  describe "clicking a link to a page requiring sign in after hovering it" do
    def open_requested_page(in_menu: false)
      visit origin_path
      click_button("dropdown_toggle_#{sealed_sake.id}") if in_menu
      hover_and_click(find(:test_id, link))
      wait_for_page(new_user_session_path)
    end

    context "with the new sake button on the index page" do
      before { open_requested_page }

      let(:origin_path) { sakes_path }
      let(:link) { "new-sake" }
      let(:requested_path) { new_sake_path }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with the edit link in the three-dot menu on the index page" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sakes_path }
      let(:link) { "edit-#{sealed_sake.id}" }
      let(:requested_path) { edit_sake_path(sealed_sake) }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with the new sake button on the show page" do
      before { open_requested_page }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "new-sake" }
      let(:requested_path) { new_sake_path }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with the edit link in the three-dot menu on the show page" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "edit-#{sealed_sake.id}" }
      let(:requested_path) { edit_sake_path(sealed_sake) }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with the copy link in the three-dot menu on the show page" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "copy_sake" }
      let(:requested_path) { new_sake_path(copied_from: sealed_sake.id) }

      it_behaves_like "redirects to the requested page after sign in"
    end
  end

  describe "confirming an action that changes a sake" do
    def change_sake_and_sign_in(in_menu: true)
      visit origin_path
      click_button("dropdown_toggle_#{sake.id}") if in_menu
      accept_confirm { click_link(link) }
      wait_for_page(new_user_session_path)
      signin_process_on_signin_page(user)
    end

    context "with opening a sealed sake from the three-dot menu on the index page" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sakes_path }
      let(:sake) { sealed_sake }
      let(:link) { "open_button_#{sake.id}" }

      it "returns to the origin page without opening the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("sealed")
      end
    end

    context "with emptying an opened sake from the three-dot menu on the index page" do
      let!(:sake) { create(:sake, bottle_level: "opened") }
      let(:origin_path) { sakes_path }
      let(:link) { "empty_button_#{sake.id}" }

      before { change_sake_and_sign_in }

      it "returns to the origin page without emptying the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("opened")
      end
    end

    context "with opening a sealed sake from the three-dot menu on the show page" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sake_path(sake) }
      let(:sake) { sealed_sake }
      let(:link) { "open_button_#{sake.id}" }

      it "returns to the origin page without opening the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("sealed")
      end
    end

    context "with emptying an opened sake from the three-dot menu on the show page" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sake_path(sake) }
      let!(:sake) { create(:sake, bottle_level: "opened") }
      let(:link) { "empty_button_#{sake.id}" }

      it "returns to the origin page without emptying the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("opened")
      end
    end

    context "with deleting a sake by the delete button on the show page" do
      before { change_sake_and_sign_in(in_menu: false) }

      let(:origin_path) { sake_path(sake) }
      let(:sake) { sealed_sake }
      let(:link) { "delete_sake" }

      it "returns to the origin page without deleting the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(Sake).to exist(sake.id)
      end
    end
  end

  describe "hovering a link and then signing in from the header" do
    before do
      visit origin_path
    end

    shared_examples "returns to the origin page after sign in" do
      it "returns to the origin page after sign in" do
        sign_in_from_header
        expect(page).to have_current_path(origin_path)
      end
    end

    shared_context "with hover on sake menu" do
      before do
        open_header_menu
        hover_and_wait(find(:test_id, "sake-menu"))
      end
    end

    shared_context "with hover on new sake" do
      before do
        hover_and_wait(find(:test_id, "new-sake"))
        open_header_menu
      end
    end

    context "with the sake menu link not requiring sign in on the index page" do
      let(:origin_path) { sakes_path }

      include_context "with hover on sake menu"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with the new sake button requiring sign in on the index page" do
      let(:origin_path) { sakes_path }

      include_context "with hover on new sake"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with the sake menu link not requiring sign in on the show page" do
      let(:origin_path) { sake_path(sealed_sake) }

      include_context "with hover on sake menu"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with the new sake button requiring sign in on the show page" do
      let(:origin_path) { sake_path(sealed_sake) }

      include_context "with hover on new sake"
      it_behaves_like "returns to the origin page after sign in"
    end
  end

  describe "opening the show page by clicking the sake name after hovering it" do
    before do
      visit sakes_path
      within(:test_id, "sake_card_#{sealed_sake.id}") { hover_and_click(find_link(sealed_sake.name)) }
      find("h1", text: sealed_sake.name)
    end

    it "returns to the show page after signing in from the header" do
      open_header_menu
      sign_in_from_header
      expect(page).to have_current_path(sake_path(sealed_sake))
    end

    it "returns to the show page without deleting the sake after deleting it and signing in", :aggregate_failures do
      accept_confirm { click_link("delete_sake") }
      wait_for_page(new_user_session_path)
      signin_process_on_signin_page(user)
      expect(page).to have_current_path(sake_path(sealed_sake))
      expect(Sake).to exist(sealed_sake.id)
    end
  end

  describe "signing in from the header on the sign in page" do
    it "redirects to the root page without a redirection loop" do
      visit new_user_session_path
      open_header_menu
      sign_in_from_header
      expect(page).to have_current_path(root_path)
    end
  end
end
