require "rails_helper"

RSpec.describe "User email change with reconfirmable" do
  let(:old_email) { "old@example.com" }
  let(:user) { create(:user, email: old_email) }
  let(:new_email) { "new@example.com" }

  before do
    # テスト前にメールキューをクリアしておく
    ActionMailer::Base.deliveries.clear

    # ユーザーがメールアドレスを変更するフロー
    sign_in(user)
    visit edit_user_registration_path
    fill_in("user_email", with: new_email)
    fill_in("user_current_password", with: user.password)
    click_button("commit")
  end

  it "sends a confirmation email to the new address" do
    latest_email = ActionMailer::Base.deliveries.last

    expect(latest_email.to).to include(new_email)
  end

  it "includes a confirmation link in the email" do
    confirmation_url = ActionMailer::Base.deliveries.last.body.encoded[%r{/users/confirmation\?confirmation_token=[^"\s<]+}]

    expect(confirmation_url).to be_present
  end

  it "applies the email change after visiting the confirmation link" do
    confirmation_url = ActionMailer::Base.deliveries.last.body.encoded[%r{/users/confirmation\?confirmation_token=[^"\s<]+}]
    visit(confirmation_url)

    expect(user.reload.email).to eq(new_email)
  end
end
