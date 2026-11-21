require "rails_helper"

RSpec.describe "Random drink" do
  let!(:sake) { create(:sake, name: "ランダム酒") }

  describe "random drink modal", :js do
    it "cleans up the modal when navigating back from the selected sake" do
      visit sakes_path
      find(:test_id, "random_drink_button").click

      expect(find(:test_id, "random_drink_result")).to have_link(sake.name)
      find(:test_id, "random_drink_result").click_link(sake.name)
      expect(page).to have_current_path(sake_path(sake))

      page.go_back

      expect(page).to have_current_path(sakes_path)
      expect(page).to have_no_css(".modal-backdrop")
      expect(page).to have_no_css("body.modal-open")
    end
  end
end
