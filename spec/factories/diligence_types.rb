# frozen_string_literal: true

FactoryBot.define do
  factory :diligence_type do
    sequence(:code) { |n| "DT#{n}" }
    name { |n| "Tipo de Diligência #{n}" }
    description { 'Descrição de teste' }
  end
end
