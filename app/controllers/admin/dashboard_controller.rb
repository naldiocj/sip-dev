class Admin::DashboardController < ApplicationController
  def index
    @process_count = policy_scope(Sip::Process).count
    @pending_count = policy_scope(Sip::Process).where(process_state_id: ProcessState.where(code: %w[REGISTADO EM_DISTRIBUICAO DISTRIBUIDO EM_INSTRUCAO PENDENTE SUSPENSO]).pluck(:id)).count
    @diligence_count = Diligence.where(estado: %w[agendada em_andamento]).count
    @mandate_count = Mandate.where(estado: %w[emitido em_andamento]).count
    @evidence_count = Evidence.count
    @org_count = Organization.count
    @user_count = User.where(status: "active").count
    @overdue_mandates = Mandate.overdue.limit(5)
    @recent_processes = policy_scope(Sip::Process).includes(:process_state, :organizacao).order(created_at: :desc).limit(10)
    @recent_evidences = Evidence.order(created_at: :desc).limit(10)

    # Chart data - processes by state
    @processes_by_state = Sip::Process.joins(:process_state).group("process_states.code").count
    @processes_by_state = @processes_by_state.sort_by { |k, v| -v }.to_h

    # Chart data - evidence by type
    @evidences_by_type = Evidence.group(:evidence_type).count
    @evidences_by_type = @evidences_by_type.sort_by { |k, v| -v }.to_h

    # Chart data - diligences by state
    @diligences_by_state = Diligence.group(:estado).count
    @diligences_by_state = @diligences_by_state.sort_by { |k, v| -v }.to_h
  end
end
