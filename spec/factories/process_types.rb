# frozen_string_literal: true

FactoryBot.define do
  factory :process_type do
    sequence(:code) { |n| "PT#{n}" }
    name { |n| "Tipo de Processo #{n}" }
    description { 'Descrição de teste' }
  end
end
