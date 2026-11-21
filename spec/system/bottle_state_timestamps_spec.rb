require "rails_helper"

RSpec.describe "Bottle State Timestamps" do
  let(:user) { create(:user) }
  let(:delta) { 5.seconds }

  # 引数で指定したbottle_levelの酒を登録する
  def create_sake(bottle_level)
    visit new_sake_path
    fill_in("sake_name", with: "生道井")
    select(I18n.t("enums.sake.bottle_level.#{bottle_level}"), from: "sake_bottle_level")
    click_button("form_submit")
    current_path.split("/").last # 作成した酒のidを返す
  end

  # 引数で指定したsakeのbottle_levelを指定した値に更新する
  def edit_bottle_level(id, bottle_level)
    visit(edit_sake_path(id))
    select(I18n.t("enums.sake.bottle_level.#{bottle_level}"), from: "sake_bottle_level")
    click_button("form_submit")
  end

  context "when creating a new sealed sake" do
    before do
      login_as(user)
      create_sake("sealed")
    end

    describe "created_at" do
      it "is close to now" do
        created_at = sake_from_show_path(page.current_path).created_at
        now = Time.current
        expect(created_at).to be_within(delta).of(now)
      end
    end
  end

  context "when creating a new opened sake" do
    before do
      login_as(user)
      create_sake("opened")
    end

    describe "created_at" do
      it "is close to now" do
        created_at = sake_from_show_path(page.current_path).created_at
        now = Time.current
        expect(created_at).to be_within(delta).of(now)
      end
    end

    describe "opened_at" do
      it "is close to now" do
        opened_at = sake_from_show_path(page.current_path).opened_at
        now = Time.current
        expect(opened_at).to be_within(delta).of(now)
      end
    end
  end

  context "when creating a new empty sake" do
    before do
      login_as(user)
      create_sake("empty")
    end

    describe "created_at" do
      it "is close to now" do
        created_at = sake_from_show_path(page.current_path).created_at
        now = Time.current
        expect(created_at).to be_within(delta).of(now)
      end
    end

    describe "opened_at" do
      it "is close to now" do
        opened_at = sake_from_show_path(page.current_path).opened_at
        now = Time.current
        expect(opened_at).to be_within(delta).of(now)
      end
    end

    describe "emptied_at" do
      it "is close to now" do
        emptied_at = sake_from_show_path(page.current_path).emptied_at
        now = Time.current
        expect(emptied_at).to be_within(delta).of(now)
      end
    end
  end

  context "when opening a sealed sake" do
    before do
      id =
        travel_to(7.days.ago) {
          login_as(user)
          create_sake("sealed")
        }
      visit(current_path) # ページをリロードしないと再ログインできない
      login_as(user)
      edit_bottle_level(id, "opened")
    end

    describe "created_at" do
      it "is not changed" do
        created_at = sake_from_show_path(page.current_path).created_at
        expect(created_at).to be_within(delta).of(7.days.ago)
      end
    end

    describe "opened_at" do
      it "is changed to close to now" do
        opened_at = sake_from_show_path(page.current_path).opened_at
        now = Time.current
        expect(opened_at).to be_within(delta).of(now)
      end
    end
  end

  context "when empting a sealed sake" do
    before do
      id =
        travel_to(7.days.ago) {
          login_as(user)
          create_sake("sealed")
        }
      visit(current_path)
      login_as(user)
      edit_bottle_level(id, "empty")
    end

    describe "created_at" do
      it "is not changed" do
        created_at = sake_from_show_path(page.current_path).created_at
        expect(created_at).to be_within(delta).of(7.days.ago)
      end
    end

    describe "opened_at" do
      it "is changed to close to now" do
        opened_at = sake_from_show_path(page.current_path).opened_at
        now = Time.current
        expect(opened_at).to be_within(delta).of(now)
      end
    end

    describe "emptied_at" do
      it "is changed to close to now" do
        emptied_at = sake_from_show_path(page.current_path).emptied_at
        now = Time.current
        expect(emptied_at).to be_within(delta).of(now)
      end
    end
  end

  context "when empting a opened sake" do
    before do
      id =
        travel_to(7.days.ago) {
          login_as(user)
          create_sake("sealed")
        }
      travel_to(4.days.ago) do
        visit(current_path)
        login_as(user)
        edit_bottle_level(id, "opened")
      end
      visit(current_path)
      login_as(user)
      edit_bottle_level(id, "empty")
    end

    describe "created_at" do
      it "is not changed" do
        created_at = sake_from_show_path(page.current_path).created_at
        expect(created_at).to be_within(delta).of(7.days.ago)
      end
    end

    describe "opened_at" do
      it "is not changed" do
        opened_at = sake_from_show_path(page.current_path).opened_at
        expect(opened_at).to be_within(delta).of(4.days.ago)
      end
    end

    describe "emptied_at" do
      it "is changed to close to now" do
        emptied_at = sake_from_show_path(page.current_path).emptied_at
        now = Time.current
        expect(emptied_at).to be_within(delta).of(now)
      end
    end
  end
end
