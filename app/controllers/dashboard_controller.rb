class DashboardController < ApplicationController
  def index
    week_start  = parse_week_param || Date.current.beginning_of_week(:sunday)
    @week_days  = DashboardWeekBuilder.new(current_user, week_start).call
    @prev_week  = week_start - 7.days
    @next_week  = week_start + 7.days
    @curr_week  = week_start
    @is_current = week_start == Date.current.beginning_of_week(:sunday)
    @habit_week_summaries = build_habit_week_summaries
    @week_summary_completed_target_count = @habit_week_summaries.sum do |summary|
      [ summary[:completed_count], summary[:target_count] ].min
    end
    @week_summary_target_count = @habit_week_summaries.sum { |summary| summary[:target_count] }
  end

  private

  def build_habit_week_summaries
    summaries = {}

    @week_days.each do |day|
      day.habits_with_entries.each do |habit_with_entry|
        habit = habit_with_entry.habit
        summaries[habit.id] ||= {
          habit: habit,
          active_days_count: 0,
          completed_count: 0
        }
        summaries[habit.id][:active_days_count] += 1
        summaries[habit.id][:completed_count] += 1 if habit_with_entry.entry&.completed?
      end
    end

    summaries.values.map do |summary|
      habit = summary[:habit]
      target_count = habit.weekly_target(summary[:active_days_count])
      completed_count = summary[:completed_count]

      summary.merge(
        target_count: target_count,
        status_label: habit_week_status(completed_count, target_count),
        status_class: habit_week_status_class(completed_count, target_count)
      )
    end
  end

  def habit_week_status(completed_count, target_count)
    return "No active days" if target_count.zero?
    return "Complete" if completed_count >= target_count
    return "Not started" if completed_count.zero?

    "In progress"
  end

  def habit_week_status_class(completed_count, target_count)
    return "bg-gray-100 text-gray-500" if target_count.zero?
    return "bg-green-100 text-green-700" if completed_count >= target_count
    return "bg-gray-100 text-gray-500" if completed_count.zero?

    "bg-amber-100 text-amber-700"
  end

  def parse_week_param
    Date.parse(params[:week]) if params[:week].present?
  rescue ArgumentError
    nil
  end
end
