require "rails_helper"

RSpec.describe "User email change with reconfirmable" do
  let(:user) { create(:user, email: "old@example.com") }

  before do
    ActionMailer::Base.deliveries.clear
    sign_in(user)
  end

  it "ユーザーがアカウント編集画面でメアドを変更し、新メアドに届いた確認リンクで反映できる" do
    visit edit_user_registration_path

    fill_in("user_email", with: "new@example.com")
    fill_in("user_current_password", with: user.password)
    click_button("commit")

    # reconfirmable: 新メアド宛に確認メールが送られる
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include("new@example.com")

    # メール本文中の確認リンクを取り出して visit
    confirmation_url = mail.body.encoded[%r{/users/confirmation\?confirmation_token=[^"\s<]+}]
    visit confirmation_url

    expect(user.reload.email).to eq("new@example.com")
  end
end
