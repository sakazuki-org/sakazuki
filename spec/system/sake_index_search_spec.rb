require "rails_helper"

RSpec.describe "Searching" do
  # 変数内を呼び出す前にページにアクセスするため、let!で確実に生成する
  let!(:sealed) { create(:sake, name: "生道井 本醸造", bottle_level: "sealed") }
  let!(:opened) { create(:sake, name: "ほしいずみ 純米", bottle_level: "opened") }
  let!(:empty) { create(:sake, name: "ほしいずみ 大吟醸", bottle_level: "empty") }

  before do
    visit sakes_path
  end

  describe "listed sakes" do
    it "includes sealed sake" do
      expect(page).to have_text(sealed.name)
    end

    it "includes opened sake" do
      expect(page).to have_text(opened.name)
    end

    it "does not include empty sake" do
      expect(page).to have_no_text(empty.name)
    end
  end

  describe "all sakes" do
    before do
      # 空検索は全酒の一覧になる
      fill_in("text_search", with: "")
      click_button("submit_search")
    end

    it "includes sealed sake" do
      expect(page).to have_text(sealed.name)
    end

    it "includes opened sake" do
      expect(page).to have_text(opened.name)
    end

    it "includes empty sake" do
      expect(page).to have_text(empty.name)
    end
  end

  describe "searched sakes" do
    before do
      fill_in("text_search", with: "ほしいずみ")
      click_button("submit_search")
    end

    it "does not include sealed sake" do
      expect(page).to have_no_text(sealed.name)
    end

    it "includes opened sake" do
      expect(page).to have_text(opened.name)
    end

    it "includes empty sake" do
      expect(page).to have_text(empty.name)
    end
  end
end
