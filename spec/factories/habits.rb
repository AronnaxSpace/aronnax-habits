FactoryBot.define do
  factory :habit do
    user

    name { FFaker::HipsterIpsum.word }
    description { FFaker::HipsterIpsum.sentence }
    start_date { Date.current - 1.day }
  end
end
