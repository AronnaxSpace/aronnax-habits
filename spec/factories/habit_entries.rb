FactoryBot.define do
  factory :habit_entry do
    habit
    date      { Date.current }
    completed { false }
    note      { FFaker::HipsterIpsum.sentence }
  end
end
