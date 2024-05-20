FactoryBot.define do
  factory :subscription do
    sequence(:subscription_id) { |id| "sub_#{id}" }
    status { :unpaid }
  end
end
