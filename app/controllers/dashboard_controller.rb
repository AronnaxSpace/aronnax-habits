class DashboardController < ApplicationController
  def index
    week_start  = parse_week_param || Date.current.beginning_of_week(:sunday)
    @week_days  = DashboardWeekBuilder.new(current_user, week_start).call
    @prev_week  = week_start - 7.days
    @next_week  = week_start + 7.days
    @curr_week  = week_start
    @is_current = week_start == Date.current.beginning_of_week(:sunday)
  end

  private

  def parse_week_param
    Date.parse(params[:week]) if params[:week].present?
  rescue ArgumentError
    nil
  end
end
