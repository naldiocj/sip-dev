# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:code) { |n| "ORG#{n}" }
    name { |n| "Organização de Teste #{n}" }
    level { 'departamento' }
    description { 'Descrição de teste' }
  end
end
