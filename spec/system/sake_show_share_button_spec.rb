require "rails_helper"

RSpec.describe "Sake Show Share Button" do
  describe "button label" do
    let(:sake) { create(:sake) }

    before do
      visit sake_path(sake.id)
    end

    it "has share text" do
      expect(find(:test_id, "share_button")).to have_link(I18n.t("sakes.show_abstract.share"))
    end
  end

  describe "share text" do
    context "without sake informations" do
      let(:no_info_sake) { create(:sake, name: "生道井") }

      before do
        visit sake_path(no_info_sake.id)
      end

      it "is with period and hidden" do
        target = find(:test_id, "share_text", visible: false).value
        expected = "生道井。 #SAKAZUKI"
        expect(target).to eq(expected)
      end
    end

    context "with informations" do
      let(:some_info_sake) {
        create(
          :sake,
          name: "生道井",
          kura: "原田酒造合資会社",
          todofuken: "愛知県",
          color: "わずかに黄色？",
          aroma_impression: "りんご系のいい香り！",
          taste_impression: "うまい。",
        )
      }

      before do
        visit sake_path(some_info_sake.id)
      end

      it "is well edited and hidden" do
        target = find(:test_id, "share_text", visible: false).value
        # 「。」「さんの」が追加される。「！」や「？」のあとは「。」が追加されない。
        expected = "原田酒造㈾#{I18n.t('helper.share.honorific')}生道井#{I18n.t('helper.share.period')}" \
                   "わずかに黄色？りんご系のいい香り！うまい。 #SAKAZUKI"
        expect(target).to have_text(expected)
      end
    end
  end
end
