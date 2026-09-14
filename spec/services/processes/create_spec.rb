# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Processes::Create, type: :service do
  let(:performed_by) { User.find_by(email: 'director@sic.gov.ao') || create(:user, :admin) }
  let(:attributes) do
    {
      numero: '2024/001/SIC',
      ano: 2024,
      titulo: 'Processo de Teste',
      resumo: 'Resumo do processo',
      data_entrada: Time.current,
      process_type_id: create(:process_type).id,
      process_nature_id: create(:process_nature).id,
      process_origin_id: create(:process_origin).id,
      process_priority_id: ProcessPriority.find_by(code: 'NORMAL')&.id || create(:process_priority, code: 'NORMAL').id,
      confidentiality_level_id: ConfidentialityLevel.find_by(code: 'INTERNO')&.id || create(:confidentiality_level, code: 'INTERNO').id
    }
  end

  subject(:service) { described_class.new(attributes: attributes, performed_by: performed_by) }

  describe '#call' do
    context 'with valid attributes' do
      it 'creates a process' do
        expect { service.call }.to change(Sip::Process, :count).by(1)
      end

      it 'sets initial state to REGISTADO' do
        process = service.call
        expect(process.process_state.code).to eq('REGISTADO')
      end

      it 'sets created_by and updated_by' do
        process = service.call
        expect(process.created_by).to eq(performed_by)
        expect(process.updated_by).to eq(performed_by)
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

      it 'returns the created process' do
        process = service.call
        expect(process).to be_a(Sip::Process)
        expect(process.numero).to eq('2024/001/SIC')
      end
    end

    context 'without authorization' do
      let(:performed_by) { create(:user) }

      it 'raises PermissionError' do
        expect { service.call }.to raise_error(Processes::Base::PermissionError)
      end
    end

    context 'with duplicate numero+ano' do
      before { create(:process, numero: '2024/001/SIC', ano: 2024) }

      it 'raises ActiveRecord::RecordInvalid' do
        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#success?' do
    it 'returns true when successful' do
      service.call
      expect(service.success?).to be true
    end

    it 'returns false when failed' do
      fail_service = described_class.new(attributes: attributes.merge(numero: nil), performed_by: performed_by)
      fail_service.call rescue nil
      expect(fail_service.success?).to be false
    end
  end

  describe '#errors' do
    it 'returns empty array when successful' do
      service.call
      expect(service.errors).to be_empty
    end

    it 'returns errors when failed' do
      fail_service = described_class.new(attributes: attributes.merge(numero: nil), performed_by: performed_by)
      fail_service.call rescue nil
      expect(fail_service.errors).not_to be_empty
    end
  end
end
