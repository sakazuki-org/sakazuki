require "rails_helper"

RSpec.describe "Sake Form Add Tax", :js do
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit new_sake_path
  end

  context "when sake price is empty" do
    it "does nothing" do
      click_button("sake_add_tax")
      expect(find(:test_id, "sake_price").value).to eq ""
    end
  end

  context "when sake price is 1000" do
    before do
      fill_in("sake_price", with: 1000)
    end

    it "changes price to 1100" do
      click_button("sake_add_tax")
      expect(find(:test_id, "sake_price").value).to eq "1100"
    end
  end

  context "when sake price is 1515, with fractions" do
    before do
      fill_in("sake_price", with: 1515)
    end

    it "changes price to 1666, floored" do
      click_button("sake_add_tax")
      expect(find(:test_id, "sake_price").value).to eq "1666"
    end
  end
end
