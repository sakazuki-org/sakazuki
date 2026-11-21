require "rails_helper"

RSpec.describe "SakeGacha" do
  describe "GET /sakes/gacha request (show)" do
    context "with in-stock sakes" do
      let!(:sealed) { create(:sake, bottle_level: "sealed") }
      let!(:opened) { create(:sake, bottle_level: "opened") }

      before { create(:sake, bottle_level: "empty") }

      it "redirects to an in-stock sake" do
        get gacha_sakes_path
        expect(response.location).to eq(sake_url(sealed)).or eq(sake_url(opened))
      end
    end

    context "without in-stock sakes" do
      before do
        create(:sake, bottle_level: "empty")
        get gacha_sakes_path
      end

      it "redirects to index page" do
        expect(response).to redirect_to sakes_path
      end

      it "has alert message" do
        expect(flash[:alert]).to eq I18n.t("sake_gacha.show.empty")
      end
    end
  end
end
