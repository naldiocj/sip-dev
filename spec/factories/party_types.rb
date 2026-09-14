# frozen_string_literal: true

FactoryBot.define do
  factory :party_type do
    sequence(:code) { |n| "PARTY#{n}" }
    name { |n| "Tipo de Parte #{n}" }
    description { 'Descrição de teste' }
  end
end
