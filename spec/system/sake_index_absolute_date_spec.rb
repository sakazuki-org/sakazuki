require "rails_helper"

RSpec.describe "Sake Index Absolute Date" do
  let(:user) { create(:user) }
  let!(:current_year_sake) { create(:sake, created_at: 3.months.ago) }
  let!(:last_year_sake) { create(:sake, created_at: 1.year.ago) }

  before do
    login_as(user)
  end

  describe "tooltip", :js do
    before do
      visit(sakes_path)
    end

    context "when mouse is over relative date of current year sake" do
      before do
        page.find("h1").hover # HACK: hover tooltip をクリア
        within(:test_id, "sake_card_#{current_year_sake.id}") do
          find("span[data-controller='tooltip']").hover
        end
      end

      it "is visible" do
        expect(page).to have_css(".tooltip")
      end

      it "displays short format date on hover" do
        expected_date = I18n.l(current_year_sake.created_at.to_date, format: :default)
        tooltip = find(".tooltip")
        expect(tooltip).to have_text(expected_date)
      end
    end

    context "when mouse is over relative date of last year sake" do
      before do
        page.find("h1").hover # HACK: hover tooltip をクリア
        within(:test_id, "sake_card_#{last_year_sake.id}") do
          find("span[data-controller='tooltip']").hover
        end
      end

      it "is visible" do
        expect(page).to have_css(".tooltip")
      end

      it "displays default format date on hover" do
        expected_date = I18n.l(last_year_sake.created_at.to_date, format: :default)
        tooltip = find(".tooltip")
        expect(tooltip).to have_text(expected_date)
      end
    end
  end
end
