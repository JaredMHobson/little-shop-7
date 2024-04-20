FactoryBot.define do
  factory :invoice do
    association :customer 
    association :coupon, strategy: :null
    status {Faker::Number.within(range: 0..2)} 
  end
end