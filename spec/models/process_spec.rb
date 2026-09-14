# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sip::Process, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:numero) }
    it { is_expected.to validate_presence_of(:ano) }
    it { is_expected.to validate_presence_of(:titulo) }
    it { is_expected.to validate_presence_of(:data_entrada) }
    let(:existing_process) { create(:process, numero: "2024/001/SIC", ano: 2024) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:process_type) }
    it { is_expected.to belong_to(:process_nature) }
    it { is_expected.to belong_to(:process_origin) }
    it { is_expected.to belong_to(:process_priority) }
    it { is_expected.to belong_to(:confidentiality_level) }
    it { is_expected.to belong_to(:process_state) }
    it { is_expected.to belong_to(:created_by).class_name('User') }
    it { is_expected.to belong_to(:updated_by).class_name('User') }
    it { is_expected.to have_many(:process_parties).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:parties).through(:process_parties).source(:person) }
    it { is_expected.to have_many(:process_locations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:process_assignments).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:process_movements).dependent(:destroy) }
    it { is_expected.to have_many(:process_transitions).dependent(:destroy) }
    it { is_expected.to have_many(:process_deadlines).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:process_legal_classifications).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:legal_references).through(:process_legal_classifications) }
    it { is_expected.to have_many(:process_closures).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:process_reopenings).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:process_audit_events).dependent(:destroy) }
  end

  describe 'methods' do
    let(:process) { create(:process) }

    describe '#current_location' do
      it 'returns the latest location' do
        location1 = create(:process_location, process: process, started_at: 2.days.ago)
        location2 = create(:process_location, process: process, started_at: 1.day.ago)
        expect(process.current_location).to eq(location2)
      end
    end

    describe '#current_assignment' do
      it 'returns the active assignment' do
        assignment = create(:process_assignment, process: process, started_at: 1.day.ago)
        expect(process.current_assignment).to eq(assignment)
      end

      it 'returns nil when no active assignment' do
        create(:process_assignment, process: process, started_at: 1.day.ago, ended_at: Time.current)
        expect(process.current_assignment).to be_nil
      end
    end

    describe '#active_deadline' do
      it 'returns the first EM_CURSO deadline' do
        deadline1 = create(:process_deadline, process: process, status: 'EM_CURSO', due_at: 10.days.from_now)
        deadline2 = create(:process_deadline, process: process, status: 'EM_CURSO', due_at: 5.days.from_now)
        expect(process.active_deadline).to eq(deadline2)
      end
    end

    describe '#days_until_deadline' do
      it 'returns days until deadline' do
        create(:process_deadline, process: process, due_at: 10.days.from_now)
        expect(process.days_until_deadline).to be_within(1).of(10)
      end
    end

    describe '#is_overdue?' do
      it 'returns true when deadline passed' do
        create(:process_deadline, process: process, due_at: 1.day.ago)
        expect(process.is_overdue?).to be true
      end

      it 'returns false when deadline not passed' do
        create(:process_deadline, process: process, due_at: 10.days.from_now)
        expect(process.is_overdue?).to be false
      end
    end
  end

  describe 'UUID generation' do
    it 'generates UUID on create' do
      process = build(:process)
      expect(process.uuid).to be_nil
      process.save!
      expect(process.uuid).not_to be_blank
    end
  end
end
