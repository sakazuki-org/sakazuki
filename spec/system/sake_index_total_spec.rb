require "rails_helper"

RSpec.describe "Sake Index Total Spec" do
  include SakesHelper

  before do
    create(:sake, bottle_level: "sealed", size: 720)
    create(:sake, bottle_level: "opened", size: 1800)
    create(:sake, bottle_level: "empty", size: 300)
  end

  describe "total amount of sake" do
    before do
      visit sakes_path
    end

    context "without empty bottle" do
      it "shows 9合 as total amount of sake" do
        # 720 + 1800/2 = 1620 ml = 9合
        expect(find(:test_id, "total_sake")).to have_text(to_shakkan(1620))
      end
    end

    context "with empty bottle", :js do
      before do
        find(:test_id, "check_empty_bottle").click
      end

      it "shows 1升5合 as total amount of sake" do
        # 720 + 1800 + 300 = 2820 ml = 1升5合
        expect(find(:test_id, "total_sake")).to have_text(to_shakkan(2820))
      end
    end
  end
end
