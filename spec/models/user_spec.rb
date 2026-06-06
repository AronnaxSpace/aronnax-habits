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
end
