require "rails_helper"

RSpec.describe "Users::Unlocks" do
  describe "GET /users/unlock/new (disabled)" do
    it "returns 404 response" do
      get "/users/unlock/new"
      expect(response).to have_http_status :not_found
    end
  end

  describe "POST /users/unlock (disabled)" do
    it "returns 404 response" do
      post "/users/unlock"
      expect(response).to have_http_status :not_found
    end
  end
end
