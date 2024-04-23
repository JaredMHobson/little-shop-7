FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code }
    code { Faker::Commerce.promotion_code(digits: 2) }
    coupon_type { Faker::Number.within(range: 0..1) }
    amount { Faker::Number.number(digits: 2) }
    status { Faker::Number.within(range: 0..1) } 
    association :merchant 
  end
end