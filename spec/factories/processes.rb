# frozen_string_literal: true

FactoryBot.define do
  factory :process, class: 'Sip::Process' do
    sequence(:numero) { |n| "2024/%03d/SIC" % n }
    ano { 2024 }
    titulo { 'Processo de Teste' }
    resumo { 'Resumo do processo' }
    data_entrada { Time.current }
    data_registo { Time.current }

    process_type { create(:process_type) }
    process_nature { create(:process_nature) }
    process_origin { create(:process_origin) }
    process_priority { ProcessPriority.find_by(code: 'NORMAL') || create(:process_priority, code: 'NORMAL') }
    confidentiality_level { ConfidentialityLevel.find_by(code: 'INTERNO') || create(:confidentiality_level, code: 'INTERNO') }
    process_state { ProcessState.find_by(code: 'REGISTADO') || create(:process_state, code: 'REGISTADO') }

    created_by { create(:user) }
    updated_by { created_by }
  end
end
