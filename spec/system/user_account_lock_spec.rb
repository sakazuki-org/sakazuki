require "rails_helper"

RSpec.describe "User account lock and unlock" do
  let(:user) { create(:user, email: "user@example.com") }

  before do
    # テスト前にメールキューをクリアしておく
    ActionMailer::Base.deliveries.clear

    # ユーザーがパスワードを複数回間違えてロックされる
    Devise.maximum_attempts.times {
      visit new_user_session_path
      fill_in("user_email", with: user.email)
      fill_in("user_password", with: "wrong_password")
      click_button("commit")
    }
  end

  it "sends an unlock email to the user" do
    expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
  end

  it "shows an error flash message" do
    expect(page).to have_content(I18n.t("devise.failure.locked"))
  end

  context "when the user visits the unlock link from the email" do
    before do
      unlock_url = ActionMailer::Base.deliveries.last.body.encoded[%r{/users/unlock\?unlock_token=[^"\s<]+}]
      visit(unlock_url)
    end

    it "unlocks and allows sign-in with the correct password" do
      sign_in_via_header_button(user)

      # ログアウトボタンが表示されていることでログインを確認
      expect(page).to have_selector(:test_id, "sign_out")
    end
  end

  context "when 1 hour later from account lock" do
    it "unlocks and allows sign-in with the correct password" do
      travel(1.hour + 1.minute) do
        sign_in_via_header_button(user)

        # ログアウトボタンが表示されていることでログインを確認
        expect(page).to have_selector(:test_id, "sign_out")
      end
    end
  end
end
