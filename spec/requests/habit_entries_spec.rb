describe "HabitEntries", type: :request do
  include_context "authenticated user"

  let(:habit) { create(:habit, user: user) }
  let(:entry) { create(:habit_entry, habit: habit, date: Date.current) }

  let(:valid_attributes)   { { date: Date.current, completed: true, note: "Done!" } }
  let(:invalid_attributes) { { date: nil, completed: true } }

  describe "GET /habits/:habit_id/entries/new" do
    it "renders a successful response" do
      get new_habit_entry_path(habit, date: Date.current)
      expect(response).to be_successful
    end
  end

  describe "POST /habits/:habit_id/entries" do
    context "with valid parameters" do
      it "creates a new HabitEntry" do
        expect {
          post habit_entries_path(habit), params: { habit_entry: valid_attributes }
        }.to change(HabitEntry, :count).by(1)
      end

      it "redirects to the dashboard" do
        post habit_entries_path(habit), params: { habit_entry: valid_attributes }
        expect(response).to redirect_to(root_path(week: Date.current.beginning_of_week(:sunday)))
      end
    end

    context "with invalid parameters" do
      it "does not create a new HabitEntry" do
        expect {
          post habit_entries_path(habit), params: { habit_entry: invalid_attributes }
        }.to change(HabitEntry, :count).by(0)
      end

      it "renders a response with 422 status" do
        post habit_entries_path(habit), params: { habit_entry: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /habits/:habit_id/entries/:id/edit" do
    it "renders a successful response" do
      get edit_habit_entry_path(habit, entry)
      expect(response).to be_successful
    end
  end

  describe "PATCH /habits/:habit_id/entries/:id" do
    context "with valid parameters" do
      it "updates the entry" do
        patch habit_entry_path(habit, entry), params: { habit_entry: { completed: true, note: "Updated" } }
        expect(entry.reload.note).to eq("Updated")
      end

      it "redirects to the dashboard" do
        patch habit_entry_path(habit, entry), params: { habit_entry: { completed: true } }
        expect(response).to redirect_to(root_path(week: entry.date.beginning_of_week(:sunday)))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch habit_entry_path(habit, entry), params: { habit_entry: { date: nil } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
