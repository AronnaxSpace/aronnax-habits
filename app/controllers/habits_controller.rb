class HabitsController < ApplicationController
  helper_method :habit

  def index
    @habits = current_user.habits
  end

  def show
  end

  def new
    @habit = Habit.new
  end

  def edit
  end

  def create
    @habit = current_user.habits.new(habit_params)

    respond_to do |format|
      if habit.save
        format.html { redirect_to habit, notice: t(".success") }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if habit.update(habit_params)
        format.html { redirect_to habit, notice: t(".success"), status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    habit.destroy!

    respond_to do |format|
      format.html { redirect_to habits_path, notice: t(".success"), status: :see_other }
    end
  end

  private

  def habit = @habit ||= current_user.habits.find(params.expect(:id))
  def habit_params = params.expect(habit: [ :name, :description, :frequency, :start_date, :end_date ])
end
