require "rails_helper"

# 検索時はデフォルトで空き瓶を含めて表示する（issue #1208）
RSpec.describe "Search With Empty Bottle", :js do
  let!(:sealed) { create(:sake, name: "獺祭 未開封", bottle_level: "sealed") }
  let!(:empty) { create(:sake, name: "獺祭 空き瓶", bottle_level: "empty") }
  let!(:other) { create(:sake, name: "別銘柄の空き瓶", bottle_level: "empty") }

  let(:label) { I18n.t("sakes.index.all_bottles") }

  before do
    visit sakes_path
    fill_in("text_search", with: "獺祭")
    click_button("submit_search")
  end

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
      expect(page).to have_checked_field(label)
    end

    context "when unchecked during search" do
      before do
        uncheck(label)
      end

      it "excludes empty sake" do
        expect(page).to have_no_text(empty.name)
      end

      it "still includes sealed sake" do
        expect(page).to have_text(sealed.name)
      end
    end
  end
end
