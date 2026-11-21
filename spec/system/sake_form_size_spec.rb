require "rails_helper"

RSpec.describe "Sake Form Size", :js do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "when creating new sake" do
    before do
      visit new_sake_path
      fill_in("sake_name", with: "生道井")
    end

    context "with 180 ml size" do
      before do
        within(:test_id, "sake_size_div") do
          # 1800と区別するため、正規表現を使う
          find("label", text: /^180$/).click
        end
        click_button("form_submit")
      end

      it "creates 180 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("180 ml")
        end
      end
    end

    context "with 300 ml size" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "300").click
        end
        click_button("form_submit")
      end

      it "creates 300 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("300 ml")
        end
      end
    end

    context "with 720 ml size" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "720").click
        end
        click_button("form_submit")
      end

      it "creates 720 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("720 ml")
        end
      end
    end

    context "with 1800 ml size" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "1800").click
        end
        click_button("form_submit")
      end

      it "creates 1800 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("1800 ml")
        end
      end
    end

    context "with 500 ml (other) size" do
      before do
        within(:test_id, "sake_size_div") do
          # その他の容量、と区別するため正規表現を使う
          label_regexp = /^#{I18n.t('sakes.form_abstract.other_size')}$/
          find("label", text: label_regexp).click
          fill_in("sake_size_other", with: "500")
        end
        click_button("form_submit")
      end

      it "creates 500 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("500 ml")
        end
      end
    end

    context "with 720 ml size after click and fill other" do
      before do
        within(:test_id, "sake_size_div") do
          # その他の容量、と区別するため正規表現を使う
          label_regexp = /^#{I18n.t('sakes.form_abstract.other_size')}$/
          find("label", text: label_regexp).click
          fill_in("sake_size_other", with: "500")
          find("label", text: "720").click
        end
        click_button("form_submit")
      end

      it "creates 720 ml sake" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_text("720 ml")
        end
      end
    end
  end

  context "when editing sake" do
    context "with 180 ml size" do
      let(:sake) { create(:sake, size: 180) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "checks 180 ml radio" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field("180")
        end
      end
    end

    context "with 300 ml size" do
      let(:sake) { create(:sake, size: 300) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "checks 300 ml radio" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field("300")
        end
      end
    end

    context "with 720 ml size" do
      let(:sake) { create(:sake, size: 720) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "checks 720 ml radio" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field("720")
        end
      end
    end

    context "with 1800 ml size" do
      let(:sake) { create(:sake, size: 1800) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "checks 1800 ml radio" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field("1800")
        end
      end
    end

    context "with 500 ml size (other)" do
      let(:sake) { create(:sake, size: 500) }

      before do
        visit edit_sake_path(sake.id)
      end

      it "checks other radio" do
        within(:test_id, "sake_size_div") do
          expect(page).to have_checked_field(I18n.t("sakes.form_abstract.other_size"))
        end
      end

      it "has 500 text" do
        within(:test_id, "sake_size_div") do
          input = find('input#sake_size_other[type="number"]')
          expect(input[:value]).to eq("500")
        end
      end
    end
  end

  describe "default size" do
    before do
      visit new_sake_path
    end

    it "is 720 ml" do
      within(:test_id, "sake_size_div") do
        expect(page).to have_checked_field("720")
      end
    end
  end

  describe "other size form enablement" do
    before do
      visit new_sake_path
    end

    context "when checked 180" do
      before do
        within(:test_id, "sake_size_div") do
          # 1800と区別するため、正規表現を使う
          find("label", text: /^180$/).click
        end
      end

      it "is disabeld" do
        input = find("input#sake_size_other")
        expect(input).to be_disabled
      end
    end

    context "when checked 300" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "300").click
        end
      end

      it "is disabeld" do
        input = find("input#sake_size_other")
        expect(input).to be_disabled
      end
    end

    context "when checked 720" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "720").click
        end
      end

      it "is disabeld" do
        input = find("input#sake_size_other")
        expect(input).to be_disabled
      end
    end

    context "when checked 1800" do
      before do
        within(:test_id, "sake_size_div") do
          find("label", text: "1800").click
        end
      end

      it "is disabeld" do
        input = find("input#sake_size_other")
        expect(input).to be_disabled
      end
    end

    context "when checked other" do
      before do
        within(:test_id, "sake_size_div") do
          # その他の容量、と区別するため正規表現を使う
          label_regexp = /^#{I18n.t('sakes.form_abstract.other_size')}$/
          find("label", text: label_regexp).click
        end
      end

      it "is enabled" do
        input = find("input#sake_size_other")
        expect(input).not_to be_disabled
      end
    end
  end
end
