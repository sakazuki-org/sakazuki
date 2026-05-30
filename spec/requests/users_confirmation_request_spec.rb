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
end
