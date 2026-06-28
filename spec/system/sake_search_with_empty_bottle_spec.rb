require "rails_helper"

# 検索時はデフォルトで空き瓶を含めて表示する（issue #1208）
RSpec.describe "Search With Empty Bottle" do
  let!(:sealed) { create(:sake, name: "生道井 未開封", bottle_level: "sealed") }
  let!(:empty) { create(:sake, name: "生道井 空き瓶", bottle_level: "empty") }
  let!(:other) { create(:sake, name: "ほしいずみ 空き瓶", bottle_level: "empty") }

  before do
    visit sakes_path
    within("#sake_search") do
      fill_in("text_search", with: "生道井")
      click_button("submit_search")
    end
  end

  # 検索ボタン経由（commit）はサーバ側でデフォルトON判定するため、JSなしで成立する
  describe "search results" do
    it "includes matched sealed sake" do
      expect(page).to have_text(sealed.name)
    end

    it "includes matched empty sake by default" do
      expect(page).to have_text(empty.name)
    end

    it "does not include unmatched sake" do
      expect(page).to have_no_text(other.name)
    end
  end

  describe "include empty toggle" do
    it "is checked while searching" do
      expect(page).to have_checked_field(I18n.t("sakes.index.all_bottles"))
    end

    # トグルOFFはonChangeでのフォーム送信に依るためJSが要る
    context "when unchecked during search", :js do
      before do
        within("#sake_search") do
          uncheck(I18n.t("sakes.index.all_bottles"))
        end
      end

      it "does not include empty sake" do
        expect(page).to have_no_text(empty.name)
      end

      it "includes sealed sake" do
        expect(page).to have_text(sealed.name)
      end

      it "does not include unmatched sake" do
        expect(page).to have_no_text(other.name)
      end
    end
  end
end
