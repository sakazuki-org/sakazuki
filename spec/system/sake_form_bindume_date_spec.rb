require "rails_helper"

RSpec.describe "Sake Form Bindume Date" do
  # SakesHelper.with_japanese_eraを使う
  include SakesHelper

  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "when visiting new sake page" do
    before do
      visit new_sake_path
    end

    it "selects this year and month" do
      bindume = "#{with_japanese_era(Time.current)} #{I18n.l(Time.current, format: '%B')}"
      expect(page).to have_select("sake_bindume_on", selected: bindume)
    end
  end

  context "when creating sake" do
    before do
      visit new_sake_path
      fill_in("sake_name", with: "生道井")
      bindume = "#{with_japanese_era(Time.current)} #{I18n.l(Time.current, format: '%B')}"
      select(bindume, from: "sake_bindume_on")
      click_button("form_submit")
    end

    it "has this year and month" do
      sake = sake_from_show_path(page.current_path)
      expect(sake.bindume_on).to eq(Time.current.to_date.beginning_of_month)
    end
  end

  context "when editing sake" do
    let(:sake) { create(:sake, bindume_on: Date.parse("2021-07-01")) }

    before do
      visit edit_sake_path(sake.id)
    end

    it "selects year and month of the sake" do
      bindume = "#{with_japanese_era(sake.bindume_on)} #{I18n.l(sake.bindume_on, format: '%B')}"
      expect(page).to have_select("sake_bindume_on", selected: bindume)
    end
  end
end
