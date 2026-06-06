describe "/profile", type: :request do
  include_context "authenticated user"

  describe "GET /show" do
    it "renders a successful response" do
      get profile_url
      expect(response).to be_successful
      expect(response.body).to include(user.profile.nickname)
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_profile_url
      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { nickname: "new_nickname", language: "en" } }

      it "updates the profile" do
        patch profile_url, params: { profile: new_attributes }
        expect(user.profile.reload.nickname).to eq("new_nickname")
      end

      it "redirects to the profile" do
        patch profile_url, params: { profile: new_attributes }
        expect(response).to redirect_to(profile_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch profile_url, params: { profile: { nickname: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
