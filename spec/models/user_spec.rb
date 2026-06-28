describe User, type: :model do
  subject(:user) { create(:user) }

  describe "associations" do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to have_many(:habits).dependent(:destroy) }
  end

  describe "after_create" do
    it "creates a profile automatically" do
      expect(user.profile).to be_present
    end

    it "derives nickname from email" do
      local_part = user.email.split("@").first
      expect(user.profile.nickname).to start_with(local_part)
    end

    context "when Current.locale is a valid language" do
      it "sets the profile language from Current.locale" do
        Current.locale = "uk"
        user = create(:user)
        expect(user.profile.language).to eq("uk")
      end
    end

    context "when Current.locale is blank" do
      it "defaults profile language to en" do
        Current.locale = nil
        user = create(:user)
        expect(user.profile.language).to eq("en")
      end
    end

    context "when Current.locale is invalid" do
      it "defaults profile language to en" do
        Current.locale = "fr"
        user = create(:user)
        expect(user.profile.language).to eq("en")
      end
    end
  end

  describe ".from_omniauth" do
    let(:auth) { aronnax_auth_hash }

    context "with no matching user" do
      it "creates a user with provider, uid, email and tokens" do
        expect { User.from_omniauth(auth) }.to change(User, :count).by(1)

        created = User.find_by(uid: "aronnax-uid-123")
        expect(created).to have_attributes(
          provider: "aronnax",
          email: "sso-user@example.com",
          aronnax_access_token: "access-token",
          aronnax_refresh_token: "refresh-token"
        )
        expect(created.aronnax_expires_at).to be_within(1.second).of(Time.at(auth.credentials.expires_at))
      end
    end

    context "when a user already has this provider and uid" do
      let!(:existing) do
        create(:user, email: "sso-user@example.com").tap do |u|
          u.update!(provider: "aronnax", uid: "aronnax-uid-123")
        end
      end

      it "returns the existing user and refreshes its tokens" do
        expect { User.from_omniauth(auth) }.not_to change(User, :count)
        expect(User.from_omniauth(auth)).to eq(existing)
        expect(existing.reload.aronnax_access_token).to eq("access-token")
      end
    end

    context "when a local account exists with the same email" do
      let!(:existing) { create(:user, email: "sso-user@example.com") }

      it "links the Aronnax identity to the existing account" do
        expect { User.from_omniauth(auth) }.not_to change(User, :count)
        expect(existing.reload).to have_attributes(provider: "aronnax", uid: "aronnax-uid-123")
      end
    end

    context "when the provider returns no token expiry" do
      let(:auth) { aronnax_auth_hash(credentials: { expires_at: nil }) }

      it "stores a nil expiry without raising" do
        expect { User.from_omniauth(auth) }.not_to raise_error
        expect(User.find_by(uid: "aronnax-uid-123").aronnax_expires_at).to be_nil
      end
    end

    context "when the provider returns no email" do
      let(:auth) { aronnax_auth_hash(info: { email: nil }) }

      it "raises RecordInvalid" do
        expect { User.from_omniauth(auth) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
