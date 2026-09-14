# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    nome_completo { 'João Silva' }
    nome_proprio { 'João' }
    apelido { 'Silva' }
    data_nascimento { 30.years.ago }
  end
end
