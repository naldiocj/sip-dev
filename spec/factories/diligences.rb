# frozen_string_literal: true

FactoryBot.define do
  factory :diligence do
    descricao { "Diligência de teste" }
    estado { "agendada" }
    data_prevista { 7.days.from_now }
    
    process { nil }
    responsavel { create(:user) }
    diligencia_type { DiligenceType.first || create(:diligence_type) }
  end
end
