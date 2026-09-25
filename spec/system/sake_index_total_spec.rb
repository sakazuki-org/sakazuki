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
      it "shows 9合 as stock of sake" do
        # 720 + 1800/2 = 1620 ml = 9合
        expect(find(:test_id, "total_sake")).to have_text(to_shakkan(1620))
      end
    end

    context "with all sakes" do
      before do
        # 空検索は全酒の一覧になる
        fill_in("text_search", with: "")
        click_button("submit_search")
      end

      it "shows 1升5合 as total amount of sake" do
        # 720 + 1800 + 300 = 2820 ml = 1升5合
        expect(find(:test_id, "total_sake")).to have_text(to_shakkan(2820))
      end
    end
  end

  describe "total amount of sake having multiple photos" do
    before do
      sake_with_photos(photo_count: 2, sake_options: { bottle_level: "sealed", size: 720 })
      visit sakes_path
      # 空検索は全酒の一覧になる
      fill_in("text_search", with: "")
      click_button("submit_search")
    end

    it "counts the sake once" do
      # 720 + 1800 + 300 + 720 = 3540 ml = 1升9合。写真の数だけ酒が重複して数えられてはいけない
      expect(find(:test_id, "total_sake")).to have_text(to_shakkan(3540))
    end
  end
end
