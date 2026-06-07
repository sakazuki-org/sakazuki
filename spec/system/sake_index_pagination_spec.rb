require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
# letでの準備はデフォルト5つまで、どうしても12本以上の酒がいるのでdisabledする
RSpec.describe "Sake Index Pagination" do
  # rubocop:disable RSpec/LetSetup
  # 変数内を呼び出す前にページにアクセスするため、let!で確実に生成する

  # rubocop:disable RSpec/IndexedLet
  # ページネーションに必要な12本以上の酒を連番で用意する

  # 酒indexページで酒はIDの降順ソートで表示される。
  # そのためlet!での定義と逆順で表示される。
  # 例えば以下の酒は、indexページで「1,2,..,12,13,empty」の順になる
  let!(:empty) { create(:sake, name: "空のお酒", bottle_level: "empty") }
  let!(:sealed13) { create(:sake, name: "未開封のお酒13", bottle_level: "sealed") }
  let!(:sealed12) { create(:sake, name: "未開封のお酒12", bottle_level: "sealed") }
  let!(:sealed11) { create(:sake, name: "未開封のお酒11", bottle_level: "sealed") }
  let!(:sealed10) { create(:sake, name: "未開封のお酒10", bottle_level: "sealed") }
  let!(:sealed9) { create(:sake, name: "未開封のお酒09", bottle_level: "sealed") }
  let!(:sealed8) { create(:sake, name: "未開封のお酒08", bottle_level: "sealed") }
  let!(:sealed7) { create(:sake, name: "未開封のお酒07", bottle_level: "sealed") }
  let!(:sealed6) { create(:sake, name: "未開封のお酒06", bottle_level: "sealed") }
  let!(:sealed5) { create(:sake, name: "未開封のお酒05", bottle_level: "sealed") }
  let!(:sealed4) { create(:sake, name: "未開封のお酒04", bottle_level: "sealed") }
  let!(:sealed3) { create(:sake, name: "未開封のお酒03", bottle_level: "sealed") }
  let!(:sealed2) { create(:sake, name: "未開封のお酒02", bottle_level: "sealed") }
  let!(:sealed1) { create(:sake, name: "未開封のお酒01", bottle_level: "sealed") }
  # rubocop:enable RSpec/IndexedLet
  # rubocop:enable RSpec/LetSetup

  before do
    visit sakes_path
  end

  context "without empty bottles" do
    it "does not exist" do
      expect(page).to have_no_css('[testid="pagination"]')
    end

    describe "listed sakes" do
      it "includes 12th sake" do
        expect(page).to have_text(sealed12.name)
      end

      it "includes 13th sake" do
        expect(page).to have_text(sealed13.name)
      end
    end
  end

  context "with empty bottles", :js do
    before do
      find(:test_id, "check_empty_bottle").click
    end

    it "exists" do
      expect(page).to have_no_css('[testid="pagination"]')
    end

    context "with page 1" do
      it "includes 12th sake" do
        expect(page).to have_text(sealed12.name)
      end

      it "does not include 13th sake" do
        expect(page).to have_no_text(sealed13.name)
      end
    end

    context "with page 2" do
      before do
        within(:test_id, "pagination") do
          click_link("2")
        end
      end

      it "does not include 12th sake" do
        expect(page).to have_no_text(sealed12.name)
      end

      it "includes 13th sake" do
        expect(page).to have_text(sealed13.name)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
