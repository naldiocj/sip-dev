# frozen_string_literal: true

FactoryBot.define do
  factory :process_assignment do
    assignment_type { 'DISTRIBUICAO' }
    started_at { 1.day.ago }
    association :process, factory: :process
    association :assigned_to_user, factory: :user
    association :assigned_to_organization, factory: :organization
    association :assigned_by, factory: :user
  end
end
