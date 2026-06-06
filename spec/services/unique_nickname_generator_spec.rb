describe UniqueNicknameGenerator do
  describe ".generate" do
    it "returns the base nickname when not taken" do
      expect(described_class.generate("available")).to eq("available")
    end

    it "appends 1 when the base nickname is taken" do
      create(:user).profile.update!(nickname: "taken")
      expect(described_class.generate("taken")).to eq("taken1")
    end

    it "increments until a unique nickname is found" do
      create(:user).profile.update!(nickname: "taken")
      create(:user).profile.update!(nickname: "taken1")
      expect(described_class.generate("taken")).to eq("taken2")
    end
  end
end
