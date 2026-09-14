# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Processes::Distribute, type: :service do
  let(:performed_by) { User.find_by(email: 'director@sic.gov.ao') || create(:user, :admin) }
  let(:process) { create(:process) }
  let(:destination_org) { performed_by.organizations.first || create(:organization) }
  let(:destination_user) { create(:user, organization: destination_org) }
  let(:reason) { 'Distribuição normal' }

  subject(:service) do
    described_class.new(
      process: process,
      destination_organization: destination_org,
      destination_user: destination_user,
      performed_by: performed_by,
      reason: reason
    )
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'distributes the process' do
        expect { service.call }.to change { process.reload.process_state.code }.from('REGISTADO').to('DISTRIBUIDO')
      end

      it 'updates organization' do
        service.call
        expect(process.reload.organizacao).to eq(destination_org)
      end

      it 'assigns responsible user' do
        service.call
        expect(process.reload.responsavel).to eq(destination_user)
      end

      it 'creates a process assignment' do
        expect { service.call }.to change(ProcessAssignment, :count).by(1)
      end

      it 'creates a process movement' do
        expect { service.call }.to change(ProcessMovement, :count).by(1)
      end

      it 'creates a process location' do
        expect { service.call }.to change(ProcessLocation, :count).by(1)
      end

      it 'creates a process transition' do
        expect { service.call }.to change(ProcessTransition, :count).by(1)
      end

      it 'creates an audit event' do
        expect { service.call }.to change(ProcessAuditEvent, :count).by(1)
      end

      it 'returns the updated process' do
        result = service.call
        expect(result).to eq(process.reload)
      end
    end

    context 'without authorization' do
      let(:performed_by) { create(:user) }

      it 'raises PermissionError' do
        expect { service.call }.to raise_error(Processes::Base::PermissionError)
      end
    end

    context 'with invalid state' do
      before { process.update!(process_state: ProcessState.find_by(code: 'EM_INSTRUCAO') || create(:process_state)) }

      it 'raises StateError' do
        expect { service.call }.to raise_error(Processes::Base::StateError)
      end
    end

    context 'with invalid scope' do
      let(:destination_org) { create(:organization) }

      it 'raises ScopeError' do
        expect { service.call }.to raise_error(Processes::Base::ScopeError)
      end
    end
  end

  describe 'history preservation' do
    it 'preserves previous assignments' do
      first_assignment = create(:process_assignment, process: process, started_at: 2.days.ago)
      
      service.call
      
      process.reload
      expect(process.process_assignments.count).to eq(2)
      expect(first_assignment.reload.ended_at).not_to be_nil
    end

    it 'preserves previous locations' do
      first_location = create(:process_location, process: process, started_at: 2.days.ago)
      
      service.call
      
      process.reload
      expect(process.process_locations.count).to eq(2)
    end
  end
end
