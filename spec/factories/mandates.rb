# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
    mandate_type { "MANDADO_JUDICIAL" }
    destino { "Tribunal da Comarca de Luanda" }
    descricao { "Mandado de comparação" }
    estado { "emitido" }
    data_emissao { 1.day.ago }
    data_prazo { 7.days.from_now }

    process { nil }
    emissor { create(:user) }
  end
end
