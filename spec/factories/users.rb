# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@sic.gov.ao" }
    sequence(:username) { |n| "user#{n}" }
    first_name { 'Utilizador' }
    last_name { 'de Teste' }
    status { 'active' }
    organization { Organization.first || create(:organization) }

    trait :admin do
      after(:create) do |user|
        direcao_profile = Profile.find_by(code: 'DIRECAO_GERAL') || create(:profile, code: 'DIRECAO_GERAL', name: 'Direcção Geral')
        UserAssignment.create!(
          user: user,
          organization: user.organization,
          profile: direcao_profile,
          role: 'director_geral',
          started_at: Time.current
        )
      end
    end
  end
end
