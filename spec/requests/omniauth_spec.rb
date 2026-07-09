describe "Aronnax OmniAuth", type: :request do
  context "when authentication succeeds for a new user" do
    before { mock_aronnax_auth }

    it "creates the user, signs them in and redirects to the dashboard" do
      expect { authenticate_with_aronnax }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(User.find_by(uid: "aronnax-uid-123")).to have_attributes(
        provider: "aronnax",
        aronnax_access_token: "access-token"
      )
    end
  end

  context "when a user already exists for this provider and uid" do
    let!(:user) do
      create(:user, email: "sso-user@example.com").tap do |u|
        u.update!(provider: "aronnax", uid: "aronnax-uid-123")
      end
    end

    before { mock_aronnax_auth }

    it "signs in without creating a new user" do
      expect { authenticate_with_aronnax }.not_to change(User, :count)
      expect(response).to redirect_to(root_path)
    end
  end

  context "when a local account exists with the same email" do
    let!(:user) { create(:user, email: "existing@example.com") }

    before { mock_aronnax_auth(info: { email: "existing@example.com" }) }

    it "links the Aronnax identity to the existing account" do
      expect { authenticate_with_aronnax }.not_to change(User, :count)
      expect(user.reload).to have_attributes(provider: "aronnax", uid: "aronnax-uid-123")
    end
  end

  context "when the profile is invalid (missing email)" do
    before { mock_aronnax_auth(info: { email: nil }) }

    it "redirects to sign in with an alert instead of raising" do
      authenticate_with_aronnax

      expect(response).to redirect_to(new_user_session_url)
      expect(flash[:alert]).to be_present
    end
  end

  context "when authentication fails" do
    before { OmniAuth.config.mock_auth[:aronnax] = :invalid_credentials }

    it "redirects to sign in with an alert" do
      authenticate_with_aronnax

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end
  end
end
