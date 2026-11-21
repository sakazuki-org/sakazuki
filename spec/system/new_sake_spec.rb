require "rails_helper"

RSpec.describe "New Sake" do
  let(:user) { create(:user) }
  let(:sake_name) { "とても美味しいお酒" }

  describe "create sake" do
    before do
      login_as(user)
      visit new_sake_path
      fill_in("sake_name", with: sake_name)
      click_button("form_submit")
    end

    it "has success flash message" do
      text = I18n.t("helper.flash.create_sake", name: sake_name)
      expect(find(:test_id, "flash_message")).to have_text(text)
    end

    it "has specified sake name" do
      expect(find("h1")).to have_text(sake_name)
    end

    it "redirect to created sake page" do
      # 酒のIDが不明なため、showページのパスであることを確認する
      expect(page).to have_current_path %r{/sakes/[0-9]+}
    end

    it "has flash message containing link to created sake" do
      # 酒のIDが不明なため、フラッシュメッセージのリンク先が現在のパスと同じことを確認する
      expect(find(:test_id, "flash_message")).to have_link(sake_name, href: current_path)
    end
  end
end
