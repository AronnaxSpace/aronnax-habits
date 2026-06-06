module HabitScoped
  extend ActiveSupport::Concern

  included do
    helper_method :habit
  end

  private

  def habit
    @habit ||= current_user.habits.find(params[:habit_id])
  end
end
