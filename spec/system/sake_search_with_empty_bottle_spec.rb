require "rails_helper"

# 検索時は空き瓶を含めて表示する（issue #1208）
RSpec.describe "Search With Empty Bottle" do
  describe "search results" do
    let!(:sealed) { create(:sake, name: "生道井 未開封", bottle_level: "sealed") }
    let!(:empty) { create(:sake, name: "生道井 空き瓶", bottle_level: "empty") }
    let!(:other) { create(:sake, name: "ほしいずみ 空き瓶", bottle_level: "empty") }

    before do
      search_for("生道井")
    end

    it "includes matched sealed sake" do
      expect(page).to have_text(sealed.name)
    end

    it "includes matched empty sake" do
      expect(page).to have_text(empty.name)
    end

    it "does not include unmatched sake" do
      expect(page).to have_no_text(other.name)
    end
  end

  describe "pagination" do
    let!(:on_next_page) { create(:sake, name: "生道井 次ページの空き瓶", bottle_level: "empty") }

    before do
      # rubocop:disable FactoryBot/ExcessiveCreateList
      # 酒はid降順に並び1ページは12本。1ページ目を埋めることで、
      # let!で先に作ったon_next_pageが2ページ目へ送られる
      create_list(:sake, 12, name: "生道井 空き瓶", bottle_level: "empty")
      # rubocop:enable FactoryBot/ExcessiveCreateList
      search_for("生道井")
      # ページネーションはPC用(.d-sm-block)とスマホ用の2つが描画され、表示はCSSで切り替わる。
      # rack_testはCSSの表示切替を解さず両方がヒットしてしまうため、PC用に限定する。
      within(:test_id, "pagination") do
        within(".d-sm-block") do
          find(:test_id, "pagination_next").click
        end
      end
    end

    it "includes empty sake on the next page" do
      expect(page).to have_text(on_next_page.name)
    end
  end

  def search_for(word)
    visit sakes_path
    within("#sake_search") do
      fill_in("text_search", with: word)
      click_button("submit_search")
    end
  end
end
