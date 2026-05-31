shared_context "authenticated user" do
  let(:user) { create(:user) }

  before do
    sign_in user
  end
end
