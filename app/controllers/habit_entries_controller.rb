class HabitEntriesController < ApplicationController
  include HabitScoped

  helper_method :entry

  def new
    @entry = habit.entries.new(date: params[:date], completed: true)
  end

  def create
    @entry = habit.entries.new(entry_params)
    if entry.save
      redirect_to root_path(week: week_for(entry)), notice: t(".success")
    else
      render :new, status: :unprocessable_content
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
  def week_for(entry) = entry.date.beginning_of_week(:sunday)
end
