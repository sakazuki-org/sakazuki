require "rails_helper"

RSpec.describe "Sake Form Completion for Detail", :js do
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit(new_sake_path)
  end

  describe "tokutei_meisho" do
    it "is completed 本醸造" do
      fill_in("sake_name", with: "生道井 本醸造").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.honjozo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 吟醸" do
      fill_in("sake_name", with: "生道井 吟醸").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.ginjo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 大吟醸" do
      fill_in("sake_name", with: "生道井 大吟醸").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.daiginjo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 純米" do
      fill_in("sake_name", with: "生道井 純米").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.junmai")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 純米吟醸" do
      fill_in("sake_name", with: "生道井 純米吟醸").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.junmai_ginjo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 純米大吟醸" do
      fill_in("sake_name", with: "生道井 純米大吟醸").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.junmai_daiginjo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 特別本醸造" do
      fill_in("sake_name", with: "生道井 特別本醸造").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.tokubetsu_honjozo")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end

    it "is completed 特別純米" do
      fill_in("sake_name", with: "生道井 特別純米").send_keys(:tab)
      selected = I18n.t("enums.sake.tokutei_meisho.tokubetsu_junmai")
      expect(page).to have_select("sake_tokutei_meisho", selected:)
    end
  end

  describe "season" do
    it "is completed 新酒" do
      fill_in("sake_name", with: "生道井 しぼりたて").send_keys(:tab)
      expect(find(:test_id, "sake_season").value).to eq("新酒")
    end

    it "is completed 夏酒" do
      fill_in("sake_name", with: "生道井 夏の吟醸").send_keys(:tab)
      expect(find(:test_id, "sake_season").value).to eq("夏酒")
    end

    it "is completed ひやおろし" do
      fill_in("sake_name", with: "生道井 ひやおろし").send_keys(:tab)
      expect(find(:test_id, "sake_season").value).to eq("ひやおろし")
    end

    it "is completed 古酒" do
      fill_in("sake_name", with: "生道井 10年大古酒").send_keys(:tab)
      expect(find(:test_id, "sake_season").value).to eq("古酒")
    end
  end

  context "with detail accordion" do
    # 以下テストは詳細アコーディオンの中なので、アコーディオンを開いておく
    before do
      click_button("accordion_detail")
    end

    describe "moto" do
      it "is completed 生酛" do
        fill_in("sake_name", with: "生道井 生酛造り").send_keys(:tab)
        selected = I18n.t("enums.sake.moto.kimoto")
        expect(page).to have_select("sake_moto", selected:)
      end

      it "is completed 山廃" do
        fill_in("sake_name", with: "生道井 山廃純米").send_keys(:tab)
        selected = I18n.t("enums.sake.moto.yamahai")
        expect(page).to have_select("sake_moto", selected:)
      end

      it "is completed 速醸" do
        fill_in("sake_name", with: "生道井 速醸").send_keys(:tab)
        selected = I18n.t("enums.sake.moto.sokujo")
        expect(page).to have_select("sake_moto", selected:)
      end

      it "is completed 水酛" do
        fill_in("sake_name", with: "生道井 水酛").send_keys(:tab)
        selected = I18n.t("enums.sake.moto.mizumoto")
        expect(page).to have_select("sake_moto", selected:)
      end
    end

    describe "shibori" do
      it "is completed 槽搾り" do
        fill_in("sake_name", with: "生道井 槽搾り").send_keys(:tab)
        expect(find(:test_id, "sake_shibori").value).to eq("槽搾り")
      end

      it "is completed 雫取り" do
        fill_in("sake_name", with: "生道井 雫どり").send_keys(:tab)
        expect(find(:test_id, "sake_shibori").value).to eq("雫取り")
      end

      it "is completed あらばしり" do
        fill_in("sake_name", with: "生道井 荒走り").send_keys(:tab)
        expect(find(:test_id, "sake_shibori").value).to eq("あらばしり")
      end

      it "is completed 中取り" do
        fill_in("sake_name", with: "生道井 中汲み").send_keys(:tab)
        expect(find(:test_id, "sake_shibori").value).to eq("中取り")
      end

      it "is completed 責め" do
        fill_in("sake_name", with: "生道井 責め").send_keys(:tab)
        expect(find(:test_id, "sake_shibori").value).to eq("責め")
      end
    end

    describe "roka" do
      it "is completed 無濾過" do
        fill_in("sake_name", with: "生道井 無ろ過").send_keys(:tab)
        expect(find(:test_id, "sake_roka").value).to eq("無濾過")
      end

      it "is completed 素濾過" do
        fill_in("sake_name", with: "生道井 素ろ過").send_keys(:tab)
        expect(find(:test_id, "sake_roka").value).to eq("素濾過")
      end
    end

    describe "hiire" do
      it "is completed 生生" do
        fill_in("sake_name", with: "生道井 無濾過生").send_keys(:tab)
        selected = I18n.t("enums.sake.hiire.namanama")
        expect(page).to have_select("sake_hiire", selected:)
      end

      it "is completed 前火入れ" do
        fill_in("sake_name", with: "生道井 生詰め").send_keys(:tab)
        selected = I18n.t("enums.sake.hiire.mae_hiire")
        expect(page).to have_select("sake_hiire", selected:)
      end

      it "is completed 後火入れ" do
        fill_in("sake_name", with: "生道井 生貯蔵酒").send_keys(:tab)
        selected = I18n.t("enums.sake.hiire.ato_hiire")
        expect(page).to have_select("sake_hiire", selected:)
      end

      it "is completed 一回火入れ" do
        fill_in("sake_name", with: "生道井 一回火入れ").send_keys(:tab)
        selected = I18n.t("enums.sake.hiire.ikkai_hiire")
        expect(page).to have_select("sake_hiire", selected:)
      end
    end

    describe "warimizu" do
      it "is completed 原酒" do
        fill_in("sake_name", with: "生道井 生原酒").send_keys(:tab)
        selected = I18n.t("enums.sake.warimizu.genshu")
        expect(page).to have_select("sake_warimizu", selected:)
      end
    end
  end
end
