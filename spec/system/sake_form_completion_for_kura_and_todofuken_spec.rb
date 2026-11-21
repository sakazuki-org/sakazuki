require "rails_helper"

RSpec.describe "Sake Form Completion for Kura and Todofuken" do
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit(new_sake_path)
  end

  describe "kura_todofuken", :js do
    context "with empty kura_todofuken" do
      before do
        fill_in("sake_name", with: "生道井 本醸造 無ろ過生原酒 袋吊り").send_keys(:tab)
      end

      it "is completed" do
        # "send_keys(:tab)" is to trigger change event.
        # https://github.com/teamcapybara/capybara/issues/2105
        expect(find(:test_id, "sake_kura_todofuken_autocompletion").value).to eq("原田酒造合資会社（愛知県）")
      end

      it "inputs '原田酒造合資会社' to hidden kura form" do
        expect(find(:test_id, "sake_kura", visible: false).value).to eq("原田酒造合資会社")
      end

      it "inputs '愛知県' to hidden todofuken form" do
        expect(find(:test_id, "sake_todofuken", visible: false).value).to eq("愛知県")
      end
    end

    context "with filled kura_todofuken" do
      before do
        fill_in("sake_kura_todofuken_autocompletion", with: "丸一酒造株式会社")
      end

      it "is not completed" do
        fill_in("sake_name", with: "生道井 本醸造 無ろ過生原酒 袋吊り").send_keys(:tab)
        expect(find(:test_id, "sake_kura_todofuken_autocompletion").value).to eq("丸一酒造株式会社")
      end
    end

    context "with duplicate meigara" do
      it "is not completed" do
        # 黒龍は、栃木県の太平酒造と、福井県の黒龍酒造との2つある
        fill_in("sake_name", with: "黒龍").send_keys(:tab)
        expect(find(:test_id, "sake_kura_todofuken_autocompletion").value).to eq("")
      end
    end
  end
end
