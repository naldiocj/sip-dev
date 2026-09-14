class Admin::AuditController < ApplicationController
  def index
    @events = ProcessAuditEvent.includes(:process, :actor)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)

    if params[:search].present?
      @events = @events.where("action ILIKE ? OR entity_type ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:process_id].present?
      @events = @events.where(process_id: params[:process_id])
    end

    @stats = {
      total: ProcessAuditEvent.count,
      today: ProcessAuditEvent.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count,
      processes: ProcessAuditEvent.distinct.count(:process_id)
    }
  end
end
