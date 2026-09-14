# frozen_string_literal: true

FactoryBot.define do
  factory :process_state do
    sequence(:code) { |n| "STATE#{n}" }
    name { |n| "Estado #{n}" }
    description { 'Descrição de teste' }
    terminal { false }
    active { true }
  end
end
