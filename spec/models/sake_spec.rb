# == Schema Information
#
# Table name: sakes
#
#  id               :bigint           not null, primary key
#  alcohol          :float
#  aminosando       :float
#  aroma_impression :text
#  aroma_value      :integer
#  awa              :string
#  bindume_on       :date
#  bottle_level     :integer          default("sealed")
#  brewery_year     :date
#  color            :string
#  emptied_at       :datetime         not null
#  genryomai        :string
#  hiire            :integer          default("unknown")
#  kakemai          :string
#  kobo             :string
#  kura             :string
#  moto             :integer          default("unknown")
#  name             :string
#  nigori           :string
#  nihonshudo       :float
#  note             :text
#  opened_at        :datetime         not null
#  price            :integer
#  rating           :integer          default(0), not null
#  roka             :string
#  sando            :float
#  season           :string
#  seimai_buai      :integer
#  shibori          :string
#  size             :integer          default(720)
#  taste_impression :text
#  taste_value      :integer
#  todofuken        :string
#  tokutei_meisho   :integer          default("none")
#  warimizu         :integer          default("unknown")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "rails_helper"

RSpec.describe Sake do
  let!(:sealed_sake) { create(:sake, bottle_level: "sealed", size: 720) }
  let!(:opened_sake) { create(:sake, bottle_level: "opened", size: 1800) }
  let!(:empty_sake) { create(:sake, bottle_level: "empty", size: 300) }

  describe "validates" do
    subject { sake.save }

    context "without name" do
      let(:sake) { build(:sake, name: "") }

      it { is_expected.to be_falsy }
    end

    context "without kura" do
      let(:sake) { build(:sake, kura: nil) }

      it { is_expected.to be_falsy }
    end

    context "without opened_at" do
      let(:sake) { build(:sake, opened_at: nil) }

      it { is_expected.to be_falsy }
    end

    context "without emptied_at" do
      let(:sake) { build(:sake, emptied_at: nil) }

      it { is_expected.to be_falsy }
    end
  end

  describe "sake.sealed?" do
    it "returns true by sealed sake" do
      expect(sealed_sake.sealed?).to be(true)
    end

    it "returns false by opened sake" do
      expect(opened_sake.sealed?).to be(false)
    end

    it "returns false by empty sake" do
      expect(empty_sake.sealed?).to be(false)
    end
  end

  describe "sake.opened?" do
    it "returns false by sealed sake" do
      expect(sealed_sake.opened?).to be(false)
    end

    it "returns true by opened sake" do
      expect(opened_sake.opened?).to be(true)
    end

    it "returns false by empty sake" do
      expect(empty_sake.opened?).to be(false)
    end
  end

  describe "Sake.alcohol_stock" do
    it "returns 1620" do
      # 720 + 1800/2
      expect(described_class.alcohol_stock).to eq(1620)
    end
  end

  describe "Sake.new_arrival?" do
    before do
      travel_to(Time.zone.parse("2022-01-30 20:30:00"))
    end

    context "when sake is sealed and created within 4 weeks" do
      let(:sake) { create(:sake, bottle_level: "sealed", created_at: Time.zone.parse("2022-01-02 10:30:00")) }

      it "returns true" do
        expect(sake.new_arrival?).to be(true)
      end
    end

    context "when sake is sealed and created more than 4 weeks ago" do
      let(:sake) { create(:sake, bottle_level: "sealed", created_at: Time.zone.parse("2022-01-01 10:30:00")) }

      it "returns false" do
        expect(sake.new_arrival?).to be(false)
      end
    end

    context "when sake is opened and created within 2 weeks" do
      let(:sake) { create(:sake, bottle_level: "opened", created_at: Time.zone.parse("2022-01-16 10:30:00")) }

      it "returns true" do
        expect(sake.new_arrival?).to be(true)
      end
    end

    context "when sake is opened and created more than 2 weeks ago" do
      let(:sake) { create(:sake, bottle_level: "opened", created_at: Time.zone.parse("2022-01-15 10:30:00")) }

      it "returns false" do
        expect(sake.new_arrival?).to be(false)
      end
    end
  end

  describe "Sake.selling_price" do
    context "without price" do
      let(:sake) { build(:sake, price: nil, size: 100) }

      it "returns nil" do
        expect(sake.selling_price).to be_nil
      end
    end

    context "without price and with zero size" do
      let(:sake) { build(:sake, price: nil, size: 0) }

      it "returns nil" do
        expect(sake.selling_price).to be_nil
      end
    end

    context "without size" do
      let(:sake) { build(:sake, price: 100, size: nil) }

      it "returns nil" do
        expect(sake.selling_price).to be_nil
      end
    end

    context "with zero size" do
      let(:sake) { build(:sake, price: 100, size: 0) }

      it "returns nil" do
        expect(sake.selling_price).to be_nil
      end
    end

    context "with 1,234 yen, 720 ml and selling rate 3" do
      let(:sake) { build(:sake, price: 1234, size: 720) }

      before do
        stub_const("#{described_class}::SELLING_RATE", 3)
      end

      it "returns 1000" do
        expect(sake.selling_price).to eq(1000)
      end
    end

    context "with 1,234 yen, 720 ml and selling rate 1.5" do
      let(:sake) { build(:sake, price: 1234, size: 720) }

      before do
        stub_const("#{described_class}::SELLING_RATE", 1.5)
      end

      it "returns 500" do
        expect(sake.selling_price).to eq(500)
      end
    end
  end
end
