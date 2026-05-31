class DashboardWeekBuilder
  WeekDay = Struct.new(:date, :habits_with_entries, keyword_init: true)
  HabitWithEntry = Struct.new(:habit, :entry, keyword_init: true)

  def initialize(user, week_start)
    @user = user
    @week_dates = (0..6).map { |i| week_start + i.days }
  end

  def call
    active_habits = @user.habits
      .where("start_date <= ?", @week_dates.last)
      .where("end_date IS NULL OR end_date >= ?", @week_dates.first)

    entries_by_key = HabitEntry
      .where(habit: active_habits, date: @week_dates)
      .index_by { |e| [ e.habit_id, e.date ] }

    @week_dates.map do |date|
      day_habits = active_habits.select { |h| h.active_on?(date) }
      WeekDay.new(
        date: date,
        habits_with_entries: day_habits.map { |habit|
          HabitWithEntry.new(habit: habit, entry: entries_by_key[[ habit.id, date ]])
        }
      )
    end
  end
end
