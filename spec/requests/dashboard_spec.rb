describe "Dashboard", type: :request do
  include_context "authenticated user"

  describe "GET /index" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end

    it "shows a weekly summary for active habits" do
      habit = create(:habit, user: user, name: "Read", frequency: :twice_a_week)
      create(:habit_entry, habit: habit, date: Date.current, completed: true)

      get "/"

      expect(response.body).to include("Week summary")
      expect(response.body).to include("Read")
      expect(response.body).to include("Twice a week")
      expect(response.body).to include("1 completion")
      expect(response.body).to include("target 2")
      expect(response.body).to include("In progress")
    end
  end
end
