return unless Rails.env.development?

USERS_COUNT = 3

HABIT_NAMES = [
  "Morning meditation", "Evening walk", "Read for 30 minutes", "Drink 8 glasses of water",
  "No social media before noon", "Journal entry", "Cold shower", "10 minutes stretching",
  "Gratitude list", "Learn something new", "No sugar after 6pm", "Sleep by 11pm"
].freeze

require "ffaker"

(1..USERS_COUNT).each do |i|
  email = "user_#{i}@aronnax.space"
  user = User.find_or_create_by!(email:) do |u|
    puts "Created user: #{email}"
  end

  habit_names = HABIT_NAMES.sample(rand(3..6))

  habit_names.each do |name|
    start_date = Date.current - rand(14..60).days
    end_date   = [ true, false, false ].sample ? start_date + rand(30..90).days : nil
    frequency  = Habit.frequencies.keys.sample

    habit = user.habits.find_or_create_by!(name:) do |h|
      h.start_date = start_date
      h.end_date   = end_date
      h.frequency  = frequency
      puts "  Created habit: #{name} (#{h.frequency_label}, #{start_date} – #{end_date || "ongoing"})"
    end

    entry_dates = (habit.start_date..[ Date.current, habit.end_date || Date.current ].min).to_a
    entry_dates.sample([ entry_dates.size * 2 / 3, 1 ].max).each do |date|
      next if date > Date.current
      habit.entries.find_or_create_by!(date:) do |e|
        e.completed = [ true, true, true, false ].sample
        e.note      = [ FFaker::HipsterIpsum.sentence, nil ].sample
      end
    end
  end
end

puts "\nDone. #{User.count} users, #{Habit.count} habits, #{HabitEntry.count} entries."
