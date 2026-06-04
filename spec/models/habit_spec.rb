describe Habit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:entries) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
  end

  describe "#weekly_target" do
    it "returns the configured weekly target capped by active days" do
      expect(build(:habit, frequency: :twice_a_week).weekly_target(1)).to eq(1)
      expect(build(:habit, frequency: :thrice_a_week).weekly_target(7)).to eq(3)
      expect(build(:habit, frequency: :daily).weekly_target(5)).to eq(5)
    end
  end
end
