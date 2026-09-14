# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mandate, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:mandate_type) }
    it { is_expected.to validate_presence_of(:destino) }
    it { is_expected.to validate_presence_of(:descricao) }
    it { is_expected.to validate_presence_of(:data_prazo) }
    it { is_expected.to validate_presence_of(:data_emissao) }
    it { is_expected.to validate_inclusion_of(:estado).in_array(%w[emitido em_andamento executado cancelado]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:process).class_name('Sip::Process').optional }
    it { is_expected.to belong_to(:emissor).class_name('User').optional }
  end

  describe 'scopes' do
    let!(:emitido) { create(:mandate, estado: 'emitido') }
    let!(:executado) { create(:mandate, estado: 'executado') }
    let!(:overdue) { create(:mandate, estado: 'emitido', data_prazo: 1.day.ago) }

    describe '.active' do
      it 'returns non-executed and non-cancelled mandates' do
        expect(Mandate.active).to match_array([emitido, overdue])
      end
    end

    describe '.overdue' do
      it 'returns overdue active mandates' do
        expect(Mandate.overdue).to eq([overdue])
      end
    end

    describe '.by_estado' do
      it 'filters by estado' do
        expect(Mandate.by_estado('executado')).to eq([executado])
      end
    end
  end

  describe '#in_user_scope?' do
    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user) }
    let(:mandate) { create(:mandate, emissor: user) }

    it 'returns true for admin' do
      expect(mandate.in_user_scope?(admin)).to be true
    end

    it 'returns false for non-admin without scope' do
      other_user = create(:user)
      expect(mandate.in_user_scope?(other_user)).to be false
    end
  end
end
