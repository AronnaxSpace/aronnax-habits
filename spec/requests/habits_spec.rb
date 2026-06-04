describe "/habits", type: :request do
  include_context "authenticated user"

  let(:valid_attributes) do
    {
      name: "My Habit",
      frequency: "twice_a_week",
      start_date: Date.current
    }
  end
  let(:invalid_attributes) do
    {
      name: "",
      start_date: nil
    }
  end
  let(:habit) { create(:habit, user: user) }

  describe "GET /index" do
    before { habit }

    it "renders a successful response" do
      get habits_url
      expect(response).to be_successful
      expect(response.body).to include(habit.name)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get habit_url(habit)
      expect(response).to be_successful
      expect(response.body).to include(habit.name)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_habit_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_habit_url(habit)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Habit" do
        expect {
          post habits_url, params: { habit: valid_attributes }
        }.to change(Habit, :count).by(1)
      end

      it "sets the selected frequency" do
        post habits_url, params: { habit: valid_attributes }
        expect(user.habits.last.frequency).to eq("twice_a_week")
      end

      it "redirects to the created habit" do
        post habits_url, params: { habit: valid_attributes }
        expect(response).to redirect_to(habit_url(user.habits.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Habit" do
        expect {
          post habits_url, params: { habit: invalid_attributes }
        }.to change(Habit, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post habits_url, params: { habit: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          name: "Updated Habit Name",
          frequency: "weekly"
        }
      }

      it "updates the requested habit" do
        patch habit_url(habit), params: { habit: new_attributes }
        habit.reload
        expect(habit.name).to eq("Updated Habit Name")
        expect(habit.frequency).to eq("weekly")
      end

      it "redirects to the habit" do
        patch habit_url(habit), params: { habit: new_attributes }
        habit.reload
        expect(response).to redirect_to(habit_url(habit))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch habit_url(habit), params: { habit: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    before { habit }

    it "destroys the requested habit" do
      expect {
        delete habit_url(habit)
      }.to change(Habit, :count).by(-1)
    end

    it "redirects to the habits list" do
      delete habit_url(habit)
      expect(response).to redirect_to(habits_url)
    end
  end
end
