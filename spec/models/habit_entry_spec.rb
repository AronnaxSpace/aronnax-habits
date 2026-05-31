describe HabitEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:habit) }
  end

  describe "validations" do
    subject { build(:habit_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:habit_id).scoped_to(:date).ignoring_case_sensitivity }

    it "is invalid with a future date" do
      entry = build(:habit_entry, date: Date.tomorrow)
      expect(entry).not_to be_valid
      expect(entry.errors[:date]).to be_present
    end

    it "is valid with today's date" do
      expect(build(:habit_entry, date: Date.current)).to be_valid
    end

    it "is valid with a past date" do
      expect(build(:habit_entry, date: Date.current - 1)).to be_valid
    end
  end
end
