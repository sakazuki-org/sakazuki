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

      ["q[all_text_cont]=foo", "q[all_text_cont]="].product(%w[html json]).each do |query, format|
        it "returns 200 with well-formed #{query} in #{format}" do
          get "#{sakes_path(format:)}?#{query}"
          expect(response).to have_http_status :ok
        end
      end

      ["q=foo", "q[]=foo", "q[all_text_cont][x]=a"].product(%w[html json]).each do |query, format|
        it "returns 400 with malformed #{query} in #{format}" do
          get "#{sakes_path(format:)}?#{query}"
          expect(response).to have_http_status :bad_request
        end
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

      it "returns errors in Japanese by default" do
        get sakes_path(format: :json, per: 0)
        expect(json[:errors][:per]).to eq ["は1..100の範囲に含めてください"]
      end

      it "returns errors in English with Accept-Language: en" do
        get sakes_path(format: :json, per: 0), headers: { "Accept-Language": "en" }
        expect(json[:errors][:per]).to eq ["must be in 1..100"]
      end

      it "returns a non-integer error" do
        get sakes_path(format: :json, per: "abc"), headers: { "Accept-Language": "en" }
        expect(json[:errors][:per]).to eq ["must be an integer"]
      end

      it "uses the first supported language in Accept-Language" do
        get sakes_path(format: :json, per: 0), headers: { "Accept-Language": "fr, en;q=0.8" }
        expect(json[:errors][:per]).to eq ["must be in 1..100"]
      end

      it "falls back to Japanese for an unsupported language" do
        get sakes_path(format: :json, per: 0), headers: { "Accept-Language": "fr" }
        expect(json[:errors][:per]).to eq ["は1..100の範囲に含めてください"]
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

  describe "JSON API with token" do
    let(:token) { "secret-token" }
    let(:sake_body) do
      string_columns = %w[
        kura todofuken color nigori awa genryomai kakemai kobo season roka shibori aroma_impression
        taste_impression note
      ]
      { name: "後の月", size: 720, **string_columns.index_with("") }
    end
    let(:json) { response.parsed_body }

    def post_sake(body: sake_body, auth: "Bearer #{token}", headers: {})
      post sakes_path(format: :json), params: { sake: body }, headers: { Authorization: auth, **headers }, as: :json
    end

    def post_multipart(photos)
      post sakes_path(format: :json), params: { sake: sake_body.merge(photos:) },
                                      headers: { Authorization: "Bearer #{token}" }
    end

    def stub_api_token(value)
      env = ENV.to_h
      env["API_TOKEN"] = value
      stub_const("ENV", env)
    end

    before { stub_api_token(token) }

    describe "authentication" do
      it "returns 401 without a token" do
        post sakes_path(format: :json), params: { sake: sake_body }, as: :json
        expect(response).to have_http_status :unauthorized
      end

      it "returns 401 with a wrong token" do
        post_sake(auth: "Bearer wrong")
        expect(response).to have_http_status :unauthorized
      end

      it "returns 401 with an empty token when API_TOKEN is not set" do
        stub_api_token(nil)
        post_sake(auth: "Bearer ")
        expect(response).to have_http_status :unauthorized
      end

      it "returns 401 with any token when API_TOKEN is not set" do
        stub_api_token(nil)
        post_sake
        expect(response).to have_http_status :unauthorized
      end

      it "returns 401 to update with a token" do
        patch sake_path(sakes.first, format: :json), params: { sake: { name: "後の月" } },
                                                     headers: { Authorization: "Bearer #{token}" }, as: :json
        expect(response).to have_http_status :unauthorized
      end

      it "does not update with a token" do
        expect {
          patch sake_path(sakes.first, format: :json), params: { sake: { name: "後の月" } },
                                                       headers: { Authorization: "Bearer #{token}" }, as: :json
        }.not_to(change { sakes.first.reload.name })
      end

      it "does not destroy with a token" do
        expect {
          delete sake_path(sakes.first, format: :json), headers: { Authorization: "Bearer #{token}" }
        }.not_to change(Sake, :count)
      end

      it "returns 401 with an empty token when API_TOKEN is empty" do
        stub_api_token("")
        post_sake(auth: "Bearer ")
        expect(response).to have_http_status :unauthorized
      end
    end

    describe "POST /sakes.json (create)" do
      it "returns 201" do
        post_sake
        expect(response).to have_http_status :created
      end

      it "returns the created sake" do
        post_sake
        expect(json).to include(id: Sake.last.id, name: "後の月")
      end

      it "returns the location of the created sake" do
        post_sake
        expect(response.location).to eq sake_url(Sake.last)
      end

      it "sets opened_at from the bottle level" do
        post_sake(body: sake_body.merge(bottle_level: "opened"))
        expect(Sake.last.opened_at).to eq Sake.last.created_at
      end

      it "returns 422 listing omitted string columns" do
        post_sake(body: { name: "後の月" })
        expect(json[:errors].keys).to match_array(sake_body.keys.map(&:to_s) - %w[name size])
      end

      it "returns 422 for a validation error" do
        post_sake(body: sake_body.merge(name: ""))
        expect(json[:errors].keys).to contain_exactly("name")
      end

      it "returns validation errors in English with Accept-Language: en" do
        post_sake(body: sake_body.merge(name: ""), headers: { "Accept-Language": "en" })
        expect(json[:errors][:name]).to eq ["can't be blank"]
      end

      it "returns 422 for an unknown enum value" do
        post_sake(body: sake_body.merge(bottle_level: "foo"))
        expect(json[:errors].keys).to contain_exactly("bottle_level")
      end

      it "returns the photos sent by multipart" do
        post_multipart(%w[sake_photo1.jpg sake_photo2.jpg].map { |name| fixture_file_upload(name, "image/jpeg") })
        expect([response.status, json[:photos].size]).to eq [201, 2]
      end

      it "returns only saved photos when one has a disallowed extension" do
        post_multipart([fixture_file_upload("sake_photo1.jpg", "image/jpeg"), fixture_file_upload("dummy.txt")])
        expect(json[:photos].pluck("id")).to eq [Sake.last.photos.sole.id]
      end

      it "ignores photos sent as strings in the JSON body" do
        expect { post_sake(body: sake_body.merge(photos: ["sake_photo1.jpg"])) }.not_to change(Photo, :count)
      end
    end

    describe "CSRF protection" do
      around do |example|
        ActionController::Base.allow_forgery_protection = true
        example.run
      ensure
        ActionController::Base.allow_forgery_protection = false
      end

      it "accepts a POST authenticated by the token" do
        expect { post_sake }.to change(Sake, :count).by 1
      end

      it "returns 401 with an empty body without the token" do
        post sakes_path(format: :json), params: { sake: sake_body }, as: :json
        expect([response.status, response.body]).to eq [401, ""]
      end

      it "rejects a JSON POST authenticated only by the session cookie" do
        login_as(create(:user))
        expect { post sakes_path(format: :json), params: { sake: sake_body }, as: :json }.not_to change(Sake, :count)
      end

      it "rejects an update by the session cookie even with the token" do
        sake = create(:sake, name: "後の月")
        login_as(create(:user))
        patch sake_path(sake), params: { sake: { name: "changed" } }, headers: { Authorization: "Bearer #{token}" }
        expect(sake.reload.name).to eq "後の月"
      end
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
