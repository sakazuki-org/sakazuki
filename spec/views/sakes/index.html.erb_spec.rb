require "rails_helper"

# Capybaraを使うためにsystem specを指定する
RSpec.describe "sakes/index", type: :system do
  let!(:sake) { sake_with_photos(sake_options: { size: 720 }) }

  before do
    visit sakes_path
  end

  describe "sake" do
    it "has link to edit" do
      buttons = "sake_buttons_#{sake.id}"
      text = I18n.t("sakes.sake.edit")
      path = edit_sake_path(sake.id)
      expect(find(:test_id, buttons)).to have_link(text, href: path)
    end

    it "has image link" do
      within(".card") do
        expect(page).to have_link(nil, href: /(jpg|avif)$/)
      end
    end

    it "has image link by SimpleLightbox", :js do
      find(".img-thumbnail").click
      expect(page).to have_current_path(sakes_path)
    end
  end

  describe "title" do
    context "without search" do
      it "shows list header" do
        expect(find("h1")).to have_text(I18n.t("sakes.index.header"))
      end

      it "shows count of stocked sake" do
        expect(find(:test_id, "total_sake")).to have_text(I18n.t("sakes.index.count", hit: 1))
      end

      it "shows amount of stocked sake" do
        expect(find(:test_id, "total_sake")).to have_text("4合")
      end
    end

    context "with search" do
      let(:search) { "ヒットしない検索語句" }

      before do
        fill_in("text_search", with: search)
        click_button("submit_search")
      end

      it "shows search word" do
        expect(find("h1")).to have_text(I18n.t("sakes.index.header_with_search", search:))
      end

      it "shows hit count" do
        expect(find(:test_id, "total_sake")).to have_text(I18n.t("sakes.index.count", hit: 0))
      end

      it "shows amount of hit sake" do
        expect(find(:test_id, "total_sake")).to have_text("0合")
      end
    end

    context "with empty search" do
      before do
        fill_in("text_search", with: "")
        click_button("submit_search")
      end

      it "shows history header" do
        expect(find("h1")).to have_text(I18n.t("sakes.index.header_history"))
      end

      it "shows count of all sake" do
        expect(find(:test_id, "total_sake")).to have_text(I18n.t("sakes.index.count", hit: 1))
      end

      it "shows amount of all sake" do
        expect(find(:test_id, "total_sake")).to have_text("4合")
      end
    end
  end

  describe "title meta tag" do
    context "without search" do
      it "has title" do
        header = "#{I18n.t('sakes.index.header')} - SAKAZUKI"
        expect(page).to have_title(header)
      end
    end

    context "with search" do
      let(:search) { "検索中の酒" }

      before do
        fill_in("text_search", with: search)
        click_button("submit_search")
      end

      it "has title with searching words" do
        header = "#{I18n.t('sakes.index.header_with_search', search:)} - SAKAZUKI"
        expect(page).to have_title(header)
      end
    end

    context "with empty search" do
      before do
        fill_in("text_search", with: "")
        click_button("submit_search")
      end

      it "has history title" do
        header = "#{I18n.t('sakes.index.header_history')} - SAKAZUKI"
        expect(page).to have_title(header)
      end
    end
  end
end
