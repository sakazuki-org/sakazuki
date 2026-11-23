require "rails_helper"

RSpec.describe "Sign-in Redirect", :js do
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

  describe "opening a page requiring sign in after hover" do
    def open_requested_page(in_menu: false)
      visit origin_path
      click_button("dropdown_toggle_#{sealed_sake.id}") if in_menu
      hover_and_click(find(:test_id, link))
      wait_for_page(new_user_session_path)
    end

    context "with new on index (A1)" do
      before { open_requested_page }

      let(:origin_path) { sakes_path }
      let(:link) { "new-sake" }
      let(:requested_path) { new_sake_path }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with edit on index (A2)" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sakes_path }
      let(:link) { "edit-#{sealed_sake.id}" }
      let(:requested_path) { edit_sake_path(sealed_sake) }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with new on show (A3)" do
      before { open_requested_page }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "new-sake" }
      let(:requested_path) { new_sake_path }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with edit on show (A4)" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "edit-#{sealed_sake.id}" }
      let(:requested_path) { edit_sake_path(sealed_sake) }

      it_behaves_like "redirects to the requested page after sign in"
    end

    context "with copy on show (A5)" do
      before { open_requested_page(in_menu: true) }

      let(:origin_path) { sake_path(sealed_sake) }
      let(:link) { "copy_sake" }
      let(:requested_path) { new_sake_path(copied_from: sealed_sake.id) }

      it_behaves_like "redirects to the requested page after sign in"
    end
  end

  describe "changing a sake" do
    def change_sake_and_sign_in(in_menu: true)
      visit origin_path
      click_button("dropdown_toggle_#{sake.id}") if in_menu
      accept_confirm { click_link(link) }
      wait_for_page(new_user_session_path)
      signin_process_on_signin_page(user)
    end

    context "with open on index (B1)" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sakes_path }
      let(:sake) { sealed_sake }
      let(:link) { "open_button_#{sake.id}" }

      it "returns to the origin page without opening the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("sealed")
      end
    end

    context "with empty on index (B2)" do
      let!(:sake) { create(:sake, bottle_level: "opened") }
      let(:origin_path) { sakes_path }
      let(:link) { "empty_button_#{sake.id}" }

      before { change_sake_and_sign_in }

      it "returns to the origin page without emptying the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("opened")
      end
    end

    context "with open on show (B3)" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sake_path(sake) }
      let(:sake) { sealed_sake }
      let(:link) { "open_button_#{sake.id}" }

      it "returns to the origin page without opening the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("sealed")
      end
    end

    context "with empty on show (B4)" do
      before { change_sake_and_sign_in }

      let(:origin_path) { sake_path(sake) }
      let!(:sake) { create(:sake, bottle_level: "opened") }
      let(:link) { "empty_button_#{sake.id}" }

      it "returns to the origin page without emptying the sake", :aggregate_failures do
        expect(page).to have_current_path(origin_path)
        expect(sake.reload.bottle_level).to eq("opened")
      end
    end

    context "with delete on show (B5)" do
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

  describe "hovering a link and signing in from header" do
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

    context "with sake menu on index (C1)" do
      let(:origin_path) { sakes_path }

      include_context "with hover on sake menu"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with new sake on index (C2)" do
      let(:origin_path) { sakes_path }

      include_context "with hover on new sake"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with sake menu on show (C3)" do
      let(:origin_path) { sake_path(sealed_sake) }

      include_context "with hover on sake menu"
      it_behaves_like "returns to the origin page after sign in"
    end

    context "with new sake on show (C4)" do
      let(:origin_path) { sake_path(sealed_sake) }

      include_context "with hover on new sake"
      it_behaves_like "returns to the origin page after sign in"
    end
  end

  describe "opening show after hover" do
    before do
      visit sakes_path
      within(:test_id, "sake_card_#{sealed_sake.id}") { hover_and_click(find_link(sealed_sake.name)) }
      find("h1", text: sealed_sake.name)
    end

    it "returns to show after sign in from header (D1)" do
      open_header_menu
      sign_in_from_header
      expect(page).to have_current_path(sake_path(sealed_sake))
    end

    it "returns to show without deleting the sake after delete (D2)", :aggregate_failures do
      accept_confirm { click_link("delete_sake") }
      wait_for_page(new_user_session_path)
      signin_process_on_signin_page(user)
      expect(page).to have_current_path(sake_path(sealed_sake))
      expect(Sake).to exist(sealed_sake.id)
    end
  end

  describe "signing in from header on sign in page (E1)" do
    it "redirects to root without redirection loop" do
      visit new_user_session_path
      open_header_menu
      sign_in_from_header
      expect(page).to have_current_path(root_path)
    end
  end
end
