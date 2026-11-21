require "rails_helper"

RSpec.describe "Edit Sake" do
  let(:sake) { create(:sake, name: "生道井") }
  let(:user) { create(:user) }

  describe "updating name" do
    before do
      login_as(user)
      visit edit_sake_path(sake.id)
      fill_in("sake_name", with: "ほしいずみ")
      click_button("form_submit")
    end

    it "redirect to sake page" do
      expect(page).to have_current_path sake_path(sake.id)
    end

    it "has success flash message" do
      sake.reload
      text = I18n.t("helper.flash.update_sake", name: sake.name)
      expect(find(:test_id, "flash_message")).to have_text(text)
    end

    it "has link to the updated sake" do
      sake.reload
      expect(find(:test_id, "flash_message")).to have_link(sake.name, href: sake_path(sake.id))
    end

    it "updates also updated_at" do
      expect { sake.reload }.to change(sake, :updated_at)
    end
  end
end
