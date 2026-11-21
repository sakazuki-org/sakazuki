require "rails_helper"

RSpec.describe "Sake Index Total Spec" do
  include SakesHelper

  before do
    # 写真の数だけ酒が重複して数えられてはいけない確認
    sake_with_photos(photo_count: 2, sake_options: { name: "生道井 本醸造", bottle_level: "sealed", size: 720 })
    create(:sake, name: "ほしいずみ 大吟醸", bottle_level: "opened", size: 1800)
    create(:sake, name: "ほしいずみ 純米", bottle_level: "empty", size: 300)
  end

  describe "total amount of sake" do
    before do
      visit sakes_path
    end

    context "without empty bottle" do
      it "shows 9合 as stock of sake" do
        # 720 + 1800/2 = 1620 ml = 9合
        expect(find(:test_id, "total_sake")).to have_text("9合")
      end
    end

    context "with all sakes" do
      before do
        # 空検索は全酒の一覧になる
        fill_in("text_search", with: "")
        click_button("submit_search")
      end

      it "shows 1升5合 as total amount of sake" do
        # 720 + 1800 + 300 = 2820 ml ≒ 1升5合 (切り捨て)
        expect(find(:test_id, "total_sake")).to have_text("1升5合")
      end
    end

    context "with searching" do
      before do
        fill_in("text_search", with: "ほしいずみ")
        click_button("submit_search")
      end

      it "shows 1升1合 as total amount of sake" do
        # 1800 + 300 = 2100 ml ≒ 1升1合 (切り捨て)
        expect(find(:test_id, "total_sake")).to have_text("1升1合")
      end
    end
  end
end
