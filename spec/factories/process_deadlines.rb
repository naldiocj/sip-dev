# frozen_string_literal: true

FactoryBot.define do
  factory :process_deadline do
    deadline_type { 'TRAMITACAO' }
    start_at { Time.current }
    due_at { 10.days.from_now }
    status { 'EM_CURSO' }
    association :process, factory: :process
    association :created_by, factory: :user
  end
end
