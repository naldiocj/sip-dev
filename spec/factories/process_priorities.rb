# frozen_string_literal: true

FactoryBot.define do
  factory :process_priority do
    sequence(:code) { |n| "PP#{n}" }
    name { |n| "Prioridade #{n}" }
    description { 'Descrição de teste' }
  end
end
