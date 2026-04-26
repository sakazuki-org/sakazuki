require "rails_helper"

RSpec.describe "Sake Form Brew Year" do
  # SakesHelper.with_japanese_eraを使う
  include SakesHelper

  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "brewery_year" do
    context "when visiting new sake page before 7/1" do
      before do
        datetime = Time.zone.parse("2022-06-30 20:30:00")
        travel_to(datetime)
        visit new_sake_path
      end

      it "selects this BY, not same with this year" do
        by = with_japanese_era(to_by(Time.current))
        expect(page).to have_select("sake_brewery_year", selected: by)
      end
    end

    context "when visiting new sake page on or after 7/1" do
      before do
        datetime = Time.zone.parse("2022-07-1 10:30:00")
        travel_to(datetime)
        visit new_sake_path
      end

      it "selects this BY, same with this year" do
        by = with_japanese_era(to_by(Time.current))
        expect(page).to have_select("sake_brewery_year", selected: by)
      end
    end

    context "when creating sake whoes BY is this year" do
      before do
        visit new_sake_path
        fill_in("sake_name", with: "生道井")
        by = with_japanese_era(to_by(Time.current))
        select(by, from: "sake_brewery_year")
        click_button("form_submit")
      end

      it "has this BY" do
        sake = sake_from_show_path(page.current_path)
        expect(sake.brewery_year).to eq(to_by(Time.current))
      end
    end

    context "when creating sake whoes BY is past year" do
      let(:ago) { Time.current.ago(10.years) }

      before do
        visit new_sake_path
        fill_in("sake_name", with: "生道井")
        by = with_japanese_era(to_by(ago))
        select(by, from: "sake_brewery_year")
        click_button("form_submit")
      end

      it "has past BY" do
        sake = sake_from_show_path(page.current_path)
        expect(sake.brewery_year).to eq(to_by(ago))
      end
    end

    context "when visiting edit page for sake having BY" do
      let(:sake) { create(:sake, brewery_year: Date.new(2021, 7, 1)) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "selects the BY of sake" do
        by = with_japanese_era(sake.brewery_year)
        expect(page).to have_select("sake_brewery_year", selected: by)
      end
    end

    context "when visiting edit page for sake not having BY" do
      let(:sake) { create(:sake, brewery_year: nil) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "selects nil" do
        text = I18n.t("sakes.form_abstract.unknown")
        expect(page).to have_select("sake_brewery_year", selected: text)
      end
    end
  end
end
