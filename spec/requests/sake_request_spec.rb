require "rails_helper"

RSpec.describe "Sakes" do
  let!(:sakes) { create_list(:sake, 3) }
  let(:id) { sakes.first.id }

  context "without login" do
    describe "GET /sakes request (index)" do
      it "returns 200 response" do
        get sakes_path
        expect(response).to have_http_status :ok
      end
    end

    describe "GET /sakes/[id] request (show)" do
      it "returns 200 response" do
        get sake_path(id)
        expect(response).to have_http_status :ok
      end
    end

    describe "GET /sakes/new request (new)" do
      it "redirects to user login page" do
        get new_sake_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET /sakes/[id]/edit (edit)" do
      it "redirects to user login page" do
        get edit_sake_path(id)
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST /sakes (create)" do
      it "redirects to user login page" do
        post sakes_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET /sakes/[id] (update)" do
      it "redirects to user login page" do
        patch sake_path(id, params: { sake: { bottle_level: "empty" } })
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "DELETE /sakes/[id] (destroy)" do
      it "redirects to user login page" do
        delete sake_path(id)
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET /sakes/menu request (menu)" do
      it "returns 200 response" do
        get menu_sakes_path
        expect(response).to have_http_status :ok
      end
    end
  end

  describe "JSON API" do
    let(:json) { response.parsed_body }
    let(:listed_ids) { json[:sakes].pluck("id") }

    describe "GET /sakes.json (index)" do
      it "returns 200 without login" do
        get sakes_path(format: :json)
        expect(response).to have_http_status :ok
      end

      it "returns sakes and meta" do
        get sakes_path(format: :json)
        expect(json.keys).to match_array %w[sakes meta]
      end

      it "includes empty bottles unlike the HTML stock list" do
        sakes.first.update!(bottle_level: :empty)
        get sakes_path(format: :json)
        expect(listed_ids).to include(sakes.first.id)
      end

      it "excludes empty bottles with q[bottle_level_not_eq]=2" do
        sakes.first.update!(bottle_level: :empty)
        get sakes_path(format: :json, q: { bottle_level_not_eq: 2 })
        expect(listed_ids).to contain_exactly(sakes.second.id, sakes.third.id)
      end

      it "ANDs q[all_text_cont] and q[bottle_level_eq]" do
        target = create(:sake, name: "後の月", bottle_level: :opened)
        create(:sake, name: "後の月", bottle_level: :sealed)
        create(:sake, name: "別の酒", bottle_level: :opened)
        get sakes_path(format: :json, q: { all_text_cont: "後の 月", bottle_level_eq: 1 })
        expect(listed_ids).to contain_exactly(target.id)
      end

      it "changes the page size with per" do
        get sakes_path(format: :json, per: 2)
        expect(json[:sakes].size).to eq 2
      end

      it "accepts per=100" do
        get sakes_path(format: :json, per: 100)
        expect(response).to have_http_status :ok
      end

      %w[0 -1 abc 101].each do |per|
        it "returns 400 with per=#{per}" do
          get sakes_path(format: :json, per:)
          expect(response).to have_http_status :bad_request
        end
      end

      %w[0 -1 abc 1000001].each do |page|
        it "returns 400 with page=#{page}" do
          get sakes_path(format: :json, page:)
          expect(response).to have_http_status :bad_request
        end
      end

      it "returns the invalid parameters in errors" do
        get sakes_path(format: :json, page: 0, per: 0)
        expect(json[:errors].keys).to contain_exactly("page", "per")
      end

      it "returns the rest of sakes on the second page" do
        get sakes_path(format: :json, per: 2, page: 2)
        expect(listed_ids).to contain_exactly(sakes.first.id)
      end

      it "returns meta matching the page" do
        get sakes_path(format: :json, per: 2, page: 2)
        expect(json[:meta]).to eq({ page: 2, per: 2, total_pages: 2, total_count: 3 }.stringify_keys)
      end
    end

    describe "GET /sakes/[id].json (show)" do
      let(:sake) { sake_with_photos(sake_options: { bottle_level: :opened }) }

      before { get sake_path(sake, format: :json) }

      it "returns all columns and photos" do
        expect(json.keys).to match_array(Sake.column_names + ["photos"])
      end

      it "returns enums as string keys" do
        expect(json[:bottle_level]).to eq "opened"
      end

      it "returns photo URLs" do
        image = sake.photos.first.image
        expect(json[:photos]).to contain_exactly(
          include(id: sake.photos.first.id, url: image.url, thumb_url: image.thumb.url),
        )
      end
    end

    it "returns 404 for an unknown sake id" do
      get sake_path(Sake.maximum(:id) + 1, format: :json)
      expect(response).to have_http_status :not_found
    end

    it "does not return to a .json path after login" do
      user = create(:user)
      get sakes_path(format: :json)
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      expect(response.location).not_to end_with ".json"
    end
  end

  context "with logined user" do
    before do
      user = create(:user)
      login_as(user)
    end

    describe "GET /sakes/[id]/edit (edit)" do
      it "returns 200 response" do
        get edit_sake_path(id)
        expect(response).to have_http_status :ok
      end
    end

    describe "POST /sakes (create)" do
      it "returns 303 response" do
        # HACK: FactoryBotで作った適当なsakeをparamsにして使う
        #       idやcreated_atなどが含まれるが、permitされてないのでparamsで渡して問題ない
        sake_params = build(:sake).attributes
        post "/sakes", params: { sake: sake_params }
        expect(response).to have_http_status :see_other # see other, and redirect to "sakes/[new_id]"
      end

      it "increase 1 sake" do
        sake_params = build(:sake).attributes
        expect { post "/sakes", params: { sake: sake_params } }.to change(Sake, :count).by 1
      end
    end

    describe "GET /sakes/[id] (update)" do
      let(:orig) { sakes.first.bottle_level }
      let(:updated) { "empty" }

      it "redirects to showing updated sake" do
        patch sake_path(id, params: { sake: { bottle_level: updated } })
        expect(response).to redirect_to sake_path(id)
      end

      it "updates sake state with patched params" do
        expect {
          patch sake_path(id, params: { sake: { bottle_level: updated } })
          sakes.first.reload
        }.to change(sakes.first, :bottle_level).from(orig).to(updated)
      end
    end

    describe "DELETE /sakes/[id] (destroy)" do
      it "redirects to index page" do
        delete sake_path(id)
        expect(response).to redirect_to sakes_path
      end

      it "decrease 1 sake" do
        expect { delete sake_path(id) }.to change(Sake, :count).by(-1)
      end
    end
  end
end
