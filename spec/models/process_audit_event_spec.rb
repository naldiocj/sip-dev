# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessAuditEvent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:process).class_name('Sip::Process') }
    it { is_expected.to belong_to(:actor).class_name('User') }
  end

  describe 'scopes' do
    let!(:event1) { create(:process_audit_event, created_at: 1.day.ago) }
    let!(:event2) { create(:process_audit_event, created_at: Time.current) }

    it 'orders by created_at desc' do
      expect(ProcessAuditEvent.order(created_at: :desc).pluck(:id)).to eq([event2.id, event1.id])
    end
  end
end
