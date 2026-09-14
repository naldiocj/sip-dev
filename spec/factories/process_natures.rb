# frozen_string_literal: true

FactoryBot.define do
  factory :process_nature do
    sequence(:code) { |n| "PN#{n}" }
    name { |n| "Natureza #{n}" }
    description { 'Descrição de teste' }
  end
end
