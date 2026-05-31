class HabitEntriesController < ApplicationController
  before_action :set_habit
  before_action :set_entry, only: [ :edit, :update ]

  def new
    @entry = @habit.entries.new(date: params[:date])
  end

  def create
    @entry = @habit.entries.new(entry_params)
    if @entry.save
      redirect_to root_path(week: week_for(@entry)), notice: "Entry saved."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to root_path(week: week_for(@entry)), notice: "Entry updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_habit  = @habit = current_user.habits.find(params[:habit_id])
  def set_entry  = @entry = @habit.entries.find(params[:id])
  def week_for(entry) = entry.date.beginning_of_week(:sunday)
  def entry_params = params.expect(habit_entry: [ :completed, :note, :date ])
end
