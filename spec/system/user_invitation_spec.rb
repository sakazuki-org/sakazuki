require "rails_helper"

RSpec.describe "User Invitation" do
  let(:admin) { create(:user, admin: true) }
  let(:user) { create(:user, admin: false) }

  before do
    sign_out(admin)
    sign_out(user)
  end

  describe "accesses to user invitation page" do
    context "when sign in as admin" do
      it "allows to access user invitation page" do
        sign_in(admin)
        visit new_user_invitation_path
        expect(page).to have_current_path new_user_invitation_path
      end
    end

    context "when sign in as user" do
      it "redirects to index page" do
        login_as(user)
        visit new_user_invitation_path
        expect(page).to have_current_path root_path
      end

      it "has error message" do
        login_as(user)
        visit new_user_invitation_path
        expect(page).to have_css(".alert-danger")
      end
    end

    context "when not sign in" do
      it "redirects to sign in page" do
        visit new_user_invitation_path
        expect(page).to have_current_path new_user_session_path
      end

      it "has error message" do
        visit new_user_invitation_path
        expect(page).to have_css(".alert-danger")
      end
    end
  end
end
