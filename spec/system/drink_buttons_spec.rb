require "rails_helper"

RSpec.describe "Drink Buttons" do
  let!(:sealed_sake) { create(:sake, bottle_level: "sealed") }
  let!(:opened_sake) { create(:sake, bottle_level: "opened") }
  let!(:empty_sake) { create(:sake, bottle_level: "empty", taste_value: 1, aroma_value: 2) }

  before do
    visit sakes_path
  end

  describe "link text" do
    let(:open_text) { I18n.t("sakes.drink_button.open") }
    let(:empty_text) { I18n.t("sakes.drink_button.empty") }

    context "with sealed bottle" do
      it "has open button with i18n text" do
        id = "sake_buttons_#{sealed_sake.id}"
        expect(find(:test_id, id)).to have_text(open_text)
      end

      it "does not have empty button with i18n text" do
        id = "sake_buttons_#{sealed_sake.id}"
        expect(find(:test_id, id)).to have_no_text(empty_text)
      end
    end

    context "with opened bottle" do
      it "does not have open button with i18n text" do
        id = "sake_buttons_#{opened_sake.id}"
        expect(find(:test_id, id)).to have_no_text(open_text)
      end

      it "has empty button with i18n text" do
        id = "sake_buttons_#{opened_sake.id}"
        expect(find(:test_id, id)).to have_text(empty_text)
      end
    end

    context "with empty bottle", :js do
      before do
        check("check_empty_bottle")
      end

      it "does not have open button with i18n text" do
        id = "sake_buttons_#{empty_sake.id}"
        expect(find(:test_id, id)).to have_no_text(open_text)
      end

      it "does not have empty button with i18n text" do
        id = "sake_buttons_#{empty_sake.id}"
        expect(find(:test_id, id)).to have_no_text(empty_text)
      end
    end
  end

  context "without login" do
    let(:user) { create(:user) }

    before do
      sign_out(user)
    end

    describe "clicking open button of sealed bottle", :js do
      before do
        click_button("dropdown_toggle_#{sealed_sake.id}")
        accept_confirm do
          click_link("open_button_#{sealed_sake.id}")
        end
        wait_for_page new_user_session_path
      end

      it "redirects to user login page" do
        expect(page).to have_current_path(new_user_session_path)
      end

      it "redirects index page after sign in", :js do
        signin_process_on_signin_page(user)
        expect(page).to have_current_path(sakes_path)
      end

      it "does not change bottle state after sign in" do
        signin_process_on_signin_page(user)
        expect { sealed_sake.reload }.not_to change(sealed_sake, :bottle_level)
      end
    end

    describe "clicking empty button of opend bottle", :js do
      before do
        click_button("dropdown_toggle_#{opened_sake.id}")
        accept_confirm do
          click_link("empty_button_#{opened_sake.id}")
        end
        wait_for_page new_user_session_path
      end

      it "redirects to user login page" do
        expect(page).to have_current_path(new_user_session_path)
      end

      it "redirects index page after sign in", :js do
        signin_process_on_signin_page(user)
        expect(page).to have_current_path(sakes_path)
      end

      it "does not change bottle state after sign in" do
        signin_process_on_signin_page(user)
        expect { opened_sake.reload }.not_to change(sealed_sake, :bottle_level)
      end
    end
  end

  context "with login" do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    describe "clicking open button of sealed bottle", :js do
      before do
        click_button("dropdown_toggle_#{sealed_sake.id}")
        accept_confirm do
          click_link("open_button_#{sealed_sake.id}")
        end
        wait_for_alert
      end

      it "reloads index page" do
        expect(page).to have_current_path(sakes_path)
      end

      it "has success flash message" do
        text = I18n.t("helper.flash.open_sake", name: sealed_sake.name, link: I18n.t("helper.flash.review"))
        expect(find(:test_id, "flash_message")).to have_text(text)
      end

      it "has flash message containing link to updated sake" do
        expect(find(:test_id, "flash_message")).to have_link(sealed_sake.name, href: sake_path(sealed_sake.id))
      end

      it "updates sake to opened" do
        expect {
          sealed_sake.reload
        }.to change(sealed_sake, :bottle_level).from("sealed").to("opened")
      end

      it "has flash message with link to review opened sake" do
        text = I18n.t("helper.flash.review")
        # HACK: クエリ部（?review=true）を無視するために正規表現でhref内容をマッチさせる
        link = /#{edit_sake_path(sealed_sake.id)}.*#headingReview/
        expect(find(:test_id, "flash_message")).to have_link(text, href: link)
      end

      it "opens review accordion after clicking review link", :js do
        click_link(I18n.t("helper.flash.review"))
        text = I18n.t("activerecord.attributes.sake.color") # レビューの中にある酒の項目の1つ
        expect(page).to have_text(text)
      end
    end

    describe "clicking empty button of opened bottle", :js do
      before do
        click_button("dropdown_toggle_#{opened_sake.id}")
        accept_confirm do
          click_link("empty_button_#{opened_sake.id}")
        end
        wait_for_alert
      end

      it "reloads to index page" do
        expect(page).to have_current_path(sakes_path)
      end

      it "has success flash message" do
        text = I18n.t("helper.flash.empty_sake", name: opened_sake.name)
        expect(find(:test_id, "flash_message")).to have_text(text)
      end

      it "has flash message containing link to updated sake" do
        expect(find(:test_id, "flash_message")).to have_link(opened_sake.name, href: sake_path(opened_sake.id))
      end

      it "updates sake to empty" do
        expect {
          opened_sake.reload
        }.to change(opened_sake, :bottle_level).from("opened").to("empty")
      end
    end
  end
end
