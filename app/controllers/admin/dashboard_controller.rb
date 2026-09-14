class Admin::DashboardController < ApplicationController
  def index
    @process_count = policy_scope(SipProcess).count
    @pending_count = policy_scope(SipProcess).where(estado: %w[REGISTADO AGUARDA_DISTRIBUICAO EM_INSTRUCAO]).count
    @diligence_count = policy_scope(Diligence).where(estado: %w[agendada em_andamento]).count
    @mandate_count = policy_scope(Mandate).where(estado: %w[emitido em_andamento]).count
    @org_count = Organization.count
  end
end
