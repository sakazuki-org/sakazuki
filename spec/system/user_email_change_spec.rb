require "rails_helper"

RSpec.describe "User email change with reconfirmable" do
  let(:user) { create(:user, email: "old@example.com") }
  let(:new_email) { "new@example.com" }

  before do
    ActionMailer::Base.deliveries.clear

    sign_in(user)
    visit edit_user_registration_path
    fill_in("user_email", with: email)
    fill_in("user_current_password", with: user.password)
    click_button("commit")
  end

  it "sends a confirmation email to the new address" do
    expect(ActionMailer::Base.deliveries.last.to).to include(new_email)
  end

  it "applies the email change after visiting the confirmation link" do
    url = ActionMailer::Base.deliveries.last.body.encoded[%r{/users/confirmation\?confirmation_token=[^"\s<]+}]
    visit(url)
    expect(user.reload.email).to eq(new_email)
  end
end
