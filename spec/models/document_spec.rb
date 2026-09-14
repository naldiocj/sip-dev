# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft submitted approved signed archived]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:process).class_name('Sip::Process').optional }
    it { is_expected.to belong_to(:uploader).class_name('User').optional }
  end

  describe 'scopes' do
    let!(:approved) { create(:document, status: 'approved') }
    let!(:draft) { create(:document, status: 'draft') }

    describe '.by_status' do
      it 'filters by status' do
        expect(Document.by_status('approved')).to eq([approved])
      end
    end

    describe '.recent' do
      it 'returns documents ordered by created_at desc' do
        expect(Document.recent.pluck(:id)).to eq([draft.id, approved.id])
      end
    end
  end

  describe '#in_user_scope?' do
    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user) }
    let(:document) { create(:document, uploader: user) }

    it 'returns true for admin' do
      expect(document.in_user_scope?(admin)).to be true
    end

    it 'returns false for non-admin without scope' do
      other_user = create(:user)
      expect(document.in_user_scope?(other_user)).to be false
    end
  end
end
