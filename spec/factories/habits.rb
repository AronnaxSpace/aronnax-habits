FactoryBot.define do
  factory :habit do
    user

    name { FFaker::HipsterIpsum.word }
    description { FFaker::HipsterIpsum.sentence }
  end
end
