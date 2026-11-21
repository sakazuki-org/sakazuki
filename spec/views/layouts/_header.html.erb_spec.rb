require "rails_helper"

# Capybaraを使うためにsystem specを指定する
RSpec.describe "layouts/_header", type: :system do
  # 常に表示するリンクのテストをshared_examplesで共通化
  RSpec.shared_examples "links always exist" do
    it "has sake menu link" do
      expect(find(:test_id, "navigation_list")).to have_link(I18n.t("layouts.header.sake_menu"), href: menu_sakes_path)
    end
  end

  describe "header links" do
    context "with signed in admin user" do
      let(:user) { create(:user, admin: true) }

      before do
        login_as(user)
        visit root_path
      end

      it_behaves_like "links always exist"

      it "does not have sign in link" do
        expect { find(:test_id, "sign_in") }.to raise_error(Capybara::ElementNotFound)
      end

      it "has user edit link" do
        expect(find(:test_id, "navigation_list")).to have_link(user.email, href: edit_user_registration_path)
      end

      it "has invitation link" do
        expect(find(:test_id, "navigation_list")).to have_link(
          I18n.t("layouts.header.invitation"),
          href: new_user_invitation_path,
        )
      end

      it "has sign out link" do
        expect(find(:test_id, "navigation_list")).to have_link(
          I18n.t("layouts.header.sign_out"), href: destroy_user_session_path
        )
      end
    end

    context "with signed in non admin user" do
      let(:user) { create(:user, admin: false) }

      before do
        login_as(user)
        visit root_path
      end

      it_behaves_like "links always exist"

      it "does not have sign in link" do
        expect { find(:test_id, "sign_in") }.to raise_error(Capybara::ElementNotFound)
      end

      it "has user edit link" do
        expect(find(:test_id, "navigation_list")).to have_link(user.email, href: edit_user_registration_path)
      end

      it "does not have invitation link" do
        expect { find(:test_id, "invitation") }.to raise_error(Capybara::ElementNotFound)
      end

      it "has sign out link" do
        expect(find(:test_id, "navigation_list")).to have_link(
          I18n.t("layouts.header.sign_out"), href: destroy_user_session_path
        )
      end
    end

    context "with not signed in user" do
      before do
        visit root_path
      end

      it_behaves_like "links always exist"

      it "has sign in link" do
        expect(find(:test_id, "navigation_list")).to have_link(
          I18n.t("layouts.header.sign_in"), href: new_user_session_path
        )
      end

      it "does not have user edit link" do
        expect { find(:test_id, "edit_user") }.to raise_error(Capybara::ElementNotFound)
      end

      it "does not have invitation link" do
        expect { find(:test_id, "invitation") }.to raise_error(Capybara::ElementNotFound)
      end

      it "does not have sign out link" do
        expect { find(:test_id, "sign_out") }.to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
