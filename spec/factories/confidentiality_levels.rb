# frozen_string_literal: true

FactoryBot.define do
  factory :confidentiality_level do
    sequence(:code) { |n| "CL#{n}" }
    name { |n| "Nível #{n}" }
    description { 'Descrição de teste' }
  end
end
