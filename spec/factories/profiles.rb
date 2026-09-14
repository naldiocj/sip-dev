# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    sequence(:code) { |n| "PROFILE#{n}" }
    name { |n| "Perfil de Teste #{n}" }
    description { 'Descrição de teste' }
  end
end
