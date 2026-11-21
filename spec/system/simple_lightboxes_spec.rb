require "rails_helper"

RSpec.describe "Simple Lightboxes", :js do
  context "with sake show page" do
    before do
      visit sake_path(sake.id)
      find(:test_id, "sake_photo").click
    end

    context "with avif photo" do
      let(:sake) { sake_with_photos }

      it "does not change current path" do
        expect(page).to have_current_path(sake_path(sake.id))
      end

      it "exists" do
        expect(page).to have_css(".simple-lightbox")
      end
    end

    context "with jpg photo" do
      let(:sake) { sake_with_photos(file_ext: "jpg") }

      it "does not change current path" do
        expect(page).to have_current_path(sake_path(sake.id))
      end

      it "exists" do
        expect(page).to have_css(".simple-lightbox")
      end
    end
  end

  context "with sake index page" do
    let!(:sakes) { sakes_with_photos(sake_count: 2) }

    before do
      visit sakes_path
      within(:test_id, "sake_card_#{sakes.first.id}") do
        find(".photo-gallery").click
      end
    end

    it "does not change current path" do
      expect(page).to have_current_path(sakes_path)
    end

    it "exists only one" do
      expect(all(:css, ".simple-lightbox").length).to eq(1)
    end
  end
end
