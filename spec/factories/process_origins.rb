# frozen_string_literal: true

FactoryBot.define do
  factory :process_origin do
    sequence(:code) { |n| "PO#{n}" }
    name { |n| "Origem #{n}" }
    description { 'Descrição de teste' }
  end
end
