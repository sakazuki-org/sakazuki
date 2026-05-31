require "rails_helper"

RSpec.describe "Sake Index Order" do
  describe "sakes order in index" do
    # 順番に意味があるのでlet!を使う
    let!(:sealed_old) { create(:sake, name: "古い未開封のお酒", bottle_level: "sealed") }
    let!(:opened_old) { create(:sake, name: "古い開封済みのお酒", bottle_level: "opened") }
    let!(:empty) { create(:sake, name: "空のお酒", bottle_level: "empty") }
    let!(:sealed_new) { create(:sake, name: "新しい未開封のお酒", bottle_level: "sealed") }
    let!(:opened_new) { create(:sake, name: "新しい開封済みのお酒", bottle_level: "opened") }

    before do
      visit sakes_path
    end

    context "without checked 'show empty bottles'" do
      it "shows opened sakes before sealed sakes" do
        regexp = /#{sealed_new.name}.*#{sealed_old.name}.*#{opened_new.name}.*#{opened_old.name}/m
        expect(page).to have_text(regexp)
      end

      it "does not include empty sake" do
        expect(page).to have_no_text(empty.name)
      end
    end

    context "with checked 'show empty bottles'", :js do
      before do
        check("check_empty_bottle") # show empty bottles
      end

      it "shows sakes sorted by id" do
        regexp = /#{sealed_new.name}.*#{sealed_old.name}.*#{opened_new.name}.*#{opened_old.name}.*#{empty.name}/m
        expect(page).to have_text(regexp)
      end
    end
  end
end
