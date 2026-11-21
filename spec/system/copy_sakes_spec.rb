require "rails_helper"

RSpec.describe "Copy Sakes" do
  # SakesHelper.with_japanese_eraを使う
  include SakesHelper

  let!(:sake) {
    create(
      :sake,
      kura: "原田酒造合資会社", todofuken: "愛知県",
      size: 1800, genryomai: "山田錦", kakemai: "五百万石",
      kobo: "協会8号", season: "新酒", roka: "無濾過",
      shibori: "雫取り", color: "黄色", nigori: "おりがらみ",
      aroma_impression: "華やかな吟醸香",
      taste_impression: "フレッシュな味",
      awa: "微炭酸", note: "今年は米が硬かった",
      bindume_on: Date.new(2002, 2, 1),
      brewery_year: Date.new(2001, 7, 1),
      taste_value: 5, aroma_value: 5, nihonshudo: 1.0,
      sando: 1.3, aminosando: 0.8, tokutei_meisho: :junmai_ginjo,
      alcohol: 18, warimizu: :genshu, moto: :sokujo, bottle_level: :empty,
      hiire: :namanama, price: 2310, rating: 5
    )
  }
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit sake_path(sake.id)
  end

  describe "copy link" do
    it "has the copy text and link in show page" do
      visit sake_path(sake.id)
      expect(find(:test_id, "copy_sake")).to have_text(I18n.t("sakes.float_button.copy"))
    end
  end

  context "when click copy link" do
    before do
      click_link("copy_sake")
    end

    describe "linked page" do
      it "links to new sake page" do
        expect(page).to have_current_path(new_sake_path, ignore_query: true)
      end
    end

    describe "flash message" do
      it "has copy message" do
        text = I18n.t("helper.flash.copy_sake", name: sake.name)
        expect(find(:test_id, "flash_message")).to have_text(text)
      end

      it "has link to copied sake on name" do
        expect(find(:test_id, "flash_message")).to have_link(sake.name, href: sake_path(sake.id))
      end
    end
  end

  describe "copied values" do
    before do
      click_link("copy_sake")
    end

    # nomarl case
    targets = %i[alcohol aminosando genryomai kakemai kobo name nihonshudo price roka sando season shibori warimizu]
    targets.each do |key|
      describe key.to_s do
        it "has copied value" do
          expect(find(:test_id, "sake_#{key}").value).to eq(sake.method(key).call.to_s)
        end
      end
    end

    # select case
    targets = %i[hiire moto tokutei_meisho warimizu]
    targets.each do |key|
      describe key.to_s do
        it "has copied value" do
          expect(page).to have_select(test_id: "sake_#{key}", selected: sake.method(:"#{key}_i18n").call)
        end
      end
    end

    # special case
    describe "kura and todofuken" do
      it "has copied kura and todofuken", :js do
        id = "sake_kura_todofuken_autocompletion"
        expect(find(:test_id, id).value).to have_text("#{sake.kura}（#{sake.todofuken}）")
      end
    end

    describe "bindume_on year" do
      it "has copied bindume year" do
        bindume = "#{with_japanese_era(sake.bindume_on)} #{I18n.l(sake.bindume_on, format: '%B')}"
        expect(page).to have_select(test_id: "sake_bindume_on", selected: bindume)
      end
    end

    describe "brewery_year" do
      it "has copied brewery_year" do
        by = with_japanese_era(sake.brewery_year)
        expect(page).to have_select(test_id: "sake_brewery_year", selected: by)
      end
    end

    describe "size", :js do
      it "has copied size" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field("1800")
        end
      end
    end
  end

  describe "not copied values" do
    before do
      click_link("copy_sake")
    end

    # normal case
    targets = %i[aroma_impression awa color nigori note taste_impression]
    targets.each do |key|
      describe key.to_s do
        it "does not have value" do
          # nil or ""
          expect(find(:test_id, "sake_#{key}").value.to_s).to eq("")
        end
      end
    end

    # hidden case
    describe "aroma_value" do
      it "does not have value" do
        expect(find(:test_id, "sake_aroma_value", visible: false).value.to_s).to eq("")
      end
    end

    describe "taste_value" do
      it "does not have value" do
        expect(find(:test_id, "sake_taste_value", visible: false).value.to_s).to eq("")
      end
    end

    describe "rating" do
      it "is 0" do
        expect(find(:test_id, "sake_rating", visible: false).value).to eq("0")
      end
    end

    # special case
    describe "bottle_level" do
      it "is sealed" do
        expect(find(:test_id, "sake_bottle_level")).to have_text(Sake.bottle_levels_i18n[:sealed])
      end
    end

    describe "photo" do
      it "does not have any photos" do
        expect(page.has_no_css?(".img-thumbnail")).to be(true)
      end
    end
  end
end
