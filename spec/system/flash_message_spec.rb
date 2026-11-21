require "rails_helper"

RSpec.describe "Flash Message" do
  let(:user) { create(:user) }
  let(:sake) { sake_with_photos }

  context "without login" do
    # sake
    describe "asscess new sake page" do
      it "has flash message" do
        visit new_sake_path
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    describe "asscess edit sake page" do
      it "has flash message" do
        visit edit_sake_path(sake.id)
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    # invitation
    describe "asscess invitation page" do
      it "has flash message" do
        visit new_user_invitation_path
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    # devise
    describe "login" do
      it "has flash message" do
        visit sakes_path
        sign_in_via_header_button(user)
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end
  end

  context "with login" do
    before do
      login_as(user)
    end

    # sake
    describe "create sake" do
      it "has flash message" do
        visit new_sake_path
        fill_in("sake_name", with: "生道井")
        click_button("form_submit")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    describe "update sake" do
      it "has flash message" do
        visit edit_sake_path(sake.id)
        fill_in("sake_name", with: "ほしいずみ")
        click_button("form_submit")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    describe "delete sake", :js do
      it "has flash message" do
        visit sake_path(sake.id)
        accept_confirm do
          click_link("delete_sake")
        end
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    describe "copy sake" do
      it "has flash message" do
        visit sake_path(sake.id)
        click_link("copy_sake")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    # photo
    describe "add photo to sake", :js do
      it "has flash message" do
        visit edit_sake_path(sake.id)
        # ファイルアップロードフィールドに画像を添付
        attach_file("sake_photos", Rails.root.join("spec/system/files/sake_photo1.avif"))
        click_button("form_submit")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    describe "delete photo from sake", :js do
      it "has flash message" do
        visit edit_sake_path(sake.id)
        # チェックボックスにチェックを入れて削除
        photo = sake.photos.first
        find(:test_id, photo.checkbox_name).click
        click_button("form_submit")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end

    # devise
    describe "logout" do
      it "has flash message" do
        visit sakes_path
        click_link("sign_out")
        expect(page).to have_selector(:test_id, "flash_message")
      end
    end
  end
end
