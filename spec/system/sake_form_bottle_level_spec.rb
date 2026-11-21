require "rails_helper"

RSpec.describe "Sake Form Bottle Level" do
  let(:user) { create(:user) }
  let(:sealed_sake) { create(:sake, bottle_level: :sealed) }
  let(:opened_sake) { create(:sake, bottle_level: :opened) }
  let(:empty_sake) { create(:sake, bottle_level: :empty) }

  before do
    login_as(user)
  end

  describe "updating sake from sealed to opened" do
    it "updates bottle level to open" do
      visit edit_sake_path(sealed_sake.id)
      select(I18n.t("enums.sake.bottle_level.opened"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { sealed_sake.reload }.to change(sealed_sake, :bottle_level).from("sealed").to("opened")
    end
  end

  describe "updating sake from sealed to empty" do
    it "updates bottle level to empty" do
      visit edit_sake_path(sealed_sake.id)
      select(I18n.t("enums.sake.bottle_level.empty"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { sealed_sake.reload }.to change(sealed_sake, :bottle_level).from("sealed").to("empty")
    end
  end

  describe "updating sake from opened to empty" do
    it "updates bottle level to empty" do
      visit edit_sake_path(opened_sake.id)
      select(I18n.t("enums.sake.bottle_level.empty"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { opened_sake.reload }.to change(opened_sake, :bottle_level).from("opened").to("empty")
    end
  end

  describe "updating sake from empty to sealed" do
    it "updates bottle level to sealed" do
      visit edit_sake_path(empty_sake.id)
      select(I18n.t("enums.sake.bottle_level.sealed"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { empty_sake.reload }.to change(empty_sake, :bottle_level).from("empty").to("sealed")
    end
  end

  describe "updating sake from empty to opened" do
    it "updates bottle level to opened" do
      visit edit_sake_path(empty_sake.id)
      select(I18n.t("enums.sake.bottle_level.opened"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { empty_sake.reload }.to change(empty_sake, :bottle_level).from("empty").to("opened")
    end
  end

  describe "updating sake from opened to sealed" do
    it "updates bottle level to sealed" do
      visit edit_sake_path(opened_sake.id)
      select(I18n.t("enums.sake.bottle_level.sealed"), from: "sake_bottle_level")
      click_button("form_submit")
      expect { opened_sake.reload }.to change(opened_sake, :bottle_level).from("opened").to("sealed")
    end
  end
end
