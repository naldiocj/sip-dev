# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Evidence, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:evidence_type) }
    it { is_expected.to validate_presence_of(:descricao) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:process).class_name('Sip::Process').optional }
    it { is_expected.to belong_to(:collector).class_name('User').optional }
  end

  describe 'scopes' do
    let!(:doc) { create(:evidence, evidence_type: 'DOCUMENTO') }
    let!(:photo) { create(:evidence, evidence_type: 'FOTO') }

    describe '.by_type' do
      it 'filters by evidence_type' do
        expect(Evidence.by_type('DOCUMENTO')).to eq([doc])
      end
    end

    describe '.recent' do
      it 'returns evidences ordered by collected_at desc' do
        expect(Evidence.recent.pluck(:id)).to eq([photo.id, doc.id])
      end
    end
  end

  describe '#in_user_scope?' do
    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user) }
    let(:evidence) { create(:evidence, collector: user) }

    it 'returns true for admin' do
      expect(evidence.in_user_scope?(admin)).to be true
    end

    it 'returns false for non-admin without scope' do
      other_user = create(:user)
      expect(evidence.in_user_scope?(other_user)).to be false
    end
  end
end
