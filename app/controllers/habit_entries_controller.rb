class HabitEntriesController < ApplicationController
  include HabitScoped

  helper_method :entry

  def new
    @entry = habit.entries.new(date: params[:date], completed: true)
  end

  def create
    @entry = habit.entries.new(entry_params)
    if entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path(week: week_for(entry)), notice: t(".success") }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def toggle_completion
    entry.update!(completed: !entry.completed)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path(week: week_for(entry)) }
    end
  end

  def edit
  end

  def update
    if entry.update(entry_params)
      redirect_to root_path(week: week_for(entry)), notice: t(".success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def entry = @entry ||= habit.entries.find(params[:id])
  def entry_params = params.expect(habit_entry: [ :completed, :note, :date ])
  def week_for(entry) = entry.date.beginning_of_week(current_user.profile.week_starts_on.to_sym)
end
