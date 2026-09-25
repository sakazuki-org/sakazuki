require "rails_helper"

RSpec.describe "With Empty Bottle" do
  # 変数内を呼び出す前にページにアクセスするため、let!で確実に生成する
  let!(:sealed) { create(:sake, name: "未開封のお酒", bottle_level: "sealed") }
  let!(:opened) { create(:sake, name: "開封済みのお酒", bottle_level: "opened") }
  let!(:empty) { create(:sake, name: "空のお酒", bottle_level: "empty") }

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

  describe "all sakes link" do
    before do
      find(:test_id, "all_sakes").click
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
end
