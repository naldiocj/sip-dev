# frozen_string_literal: true

FactoryBot.define do
  factory :process_location do
    sequence(:started_at) { |n| 10.days.ago + n.hours }
    association :process, factory: :process
    association :organization, factory: :organization
    association :created_by, factory: :user
  end
end
