# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diligence, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:descricao) }
    it { is_expected.to validate_inclusion_of(:estado).in_array(%w[agendada em_andamento concluida cancelada]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:process).class_name('Sip::Process').optional }
    it { is_expected.to belong_to(:responsavel).class_name('User').optional }
    it { is_expected.to belong_to(:diligencia_type).class_name('DiligenceType').optional }
  end

  describe 'scopes' do
    let!(:agendada) { create(:diligence, estado: 'agendada') }
    let!(:em_andamento) { create(:diligence, estado: 'em_andamento') }
    let!(:concluida) { create(:diligence, estado: 'concluida') }

    describe '.active' do
      it 'returns non-concluded and non-cancelled diligences' do
        expect(Diligence.active).to match_array([agendada, em_andamento])
      end
    end

    describe '.by_estado' do
      it 'filters by estado' do
        expect(Diligence.by_estado('concluida')).to eq([concluida])
      end
    end
  end

  describe '#in_user_scope?' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:diligence) { create(:diligence, responsavel: user) }

    it 'returns true for admin' do
      expect(diligence.in_user_scope?(admin)).to be true
    end

    it 'returns true when user is responsible' do
      expect(diligence.in_user_scope?(user)).to be true
    end

    it 'returns false for unrelated user' do
      other_user = create(:user)
      expect(diligence.in_user_scope?(other_user)).to be false
    end
  end

  describe 'class .in_user_scope?' do
    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user) }

    it 'returns true for admin' do
      expect(Diligence.in_user_scope?(admin)).to be true
    end

    it 'returns false for non-admin without scope' do
      expect(Diligence.in_user_scope?(user)).to be false
    end
  end
end
