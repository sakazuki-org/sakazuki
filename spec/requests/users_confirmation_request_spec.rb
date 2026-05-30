require "rails_helper"

RSpec.describe "Users::Confirmations" do
  describe "GET /users/confirmation/new (disabled)" do
    it "returns 404 response" do
      get "/users/confirmation/new"
      expect(response).to have_http_status :not_found
    end
  end

  describe "POST /users/confirmation (disabled)" do
    it "returns 404 response" do
      post "/users/confirmation"
      expect(response).to have_http_status :not_found
    end
  end

  # 有効な confirmation_token を伴う正規フロー (reconfirmable によるメアド変更)
  # はメール送信を含む E2E のためここではテストしない。
  # spec/system/user_email_change_spec.rb を参照。
  describe "GET /users/confirmation" do
    context "without confirmation_token" do
      it "returns 404 response" do
        get "/users/confirmation"
        expect(response).to have_http_status :not_found
      end
    end

    context "with invalid confirmation_token" do
      it "returns 404 response" do
        get "/users/confirmation", params: { confirmation_token: "invalid_token" }
        expect(response).to have_http_status :not_found
      end
    end
  end
end
