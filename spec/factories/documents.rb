# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    sequence(:title) { |n| "Documento de teste #{n}" }
    description { 'Descrição do documento' }
    status { 'draft' }
    
    process { nil }
    uploader { create(:user) }
  end
end
