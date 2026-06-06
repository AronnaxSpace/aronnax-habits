describe Profile, type: :model do
  subject { create(:user).profile }

  describe "enums" do
    it { is_expected.to define_enum_for(:language).with_values(en: 0, uk: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_uniqueness_of(:nickname) }
  end
end
