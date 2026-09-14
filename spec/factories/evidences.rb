# frozen_string_literal: true

FactoryBot.define do
  factory :evidence do
    evidence_type { "DOCUMENTO" }
    descricao { "Evidência de teste" }
    collected_at { Time.current }

    process { nil }
    collector { create(:user) }
  end
end
