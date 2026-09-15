class Admin::ReportsController < ApplicationController
  skip_before_action :authenticate_account!, only: [ :processes, :diligences, :mandates, :evidences ]
  skip_before_action :verify_authenticity_token, only: [ :processes, :diligences, :mandates, :evidences ], raise: false

  def processes
    @processes = policy_scope(Sip::Process)
      .includes(:process_state, :organizacao, :responsavel, :process_type)
      .order(created_at: :desc)

    if params[:format] == "pdf"
      respond_to do |format|
        format.html { render layout: false }
        format.pdf do
          html = render_to_string(template: "admin/reports/processes", layout: "reports")
          pdf = WickedPdf.new.pdf_from_string(html,
            margin: { top: 40, bottom: 40, left: 40, right: 40 }
          )
          send_data pdf, filename: "processos_#{Time.current.strftime('%Y%m%d')}.pdf", type: "application/pdf"
        end
      end
    else
      respond_to do |format|
        format.html
        format.xlsx do
          xlsx = generate_processes_xlsx
          send_data xlsx, filename: "processos_#{Time.current.strftime('%Y%m%d')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
      end
    end
  end

  def diligences
    @diligences = Diligence.includes(:process, :responsavel, :diligencia_type).order(created_at: :desc)

    if params[:format] == "pdf"
      respond_to do |format|
        format.pdf do
          html = render_to_string(template: "admin/reports/diligences", layout: "reports")
          pdf = WickedPdf.new.pdf_from_string(html,
            margin: { top: 40, bottom: 40, left: 40, right: 40 }
          )
          send_data pdf, filename: "diligencias_#{Time.current.strftime('%Y%m%d')}.pdf", type: "application/pdf"
        end
      end
    else
      respond_to do |format|
        format.html
        format.xlsx do
          xlsx = generate_diligences_xlsx
          send_data xlsx, filename: "diligencias_#{Time.current.strftime('%Y%m%d')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
      end
    end
  end

  def mandates
    @mandates = Mandate.includes(:process, :emissor).order(created_at: :desc)

    if params[:format] == "pdf"
      respond_to do |format|
        format.pdf do
          html = render_to_string(template: "admin/reports/mandates", layout: "reports")
          pdf = WickedPdf.new.pdf_from_string(html,
            margin: { top: 40, bottom: 40, left: 40, right: 40 }
          )
          send_data pdf, filename: "mandados_#{Time.current.strftime('%Y%m%d')}.pdf", type: "application/pdf"
        end
      end
    else
      respond_to do |format|
        format.html
        format.xlsx do
          xlsx = generate_mandates_xlsx
          send_data xlsx, filename: "mandados_#{Time.current.strftime('%Y%m%d')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
      end
    end
  end

  def evidences
    @evidences = Evidence.includes(:process, :collector).order(created_at: :desc)

    if params[:format] == "pdf"
      respond_to do |format|
        format.pdf do
          html = render_to_string(template: "admin/reports/evidences", layout: "reports")
          pdf = WickedPdf.new.pdf_from_string(html,
            margin: { top: 40, bottom: 40, left: 40, right: 40 }
          )
          send_data pdf, filename: "evidencias_#{Time.current.strftime('%Y%m%d')}.pdf", type: "application/pdf"
        end
      end
    else
      respond_to do |format|
        format.html
        format.xlsx do
          xlsx = generate_evidences_xlsx
          send_data xlsx, filename: "evidencias_#{Time.current.strftime('%Y%m%d')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
      end
    end
  end

  private

  def generate_processes_xlsx
    xlsx = Axlsx::Package.new
    wb = xlsx.workbook
    wb.add_worksheet(name: "Processos") do |sheet|
      sheet.add_row [ "Número", "Ano", "Título", "Estado", "Organização", "Responsável", "Data Entrada", "Criado em" ]
      @processes.each do |p|
        sheet.add_row [
          p.numero,
          p.ano,
          p.titulo,
          p.state_code,
          p.organizacao&.name,
          p.responsavel&.full_name,
          p.data_entrada&.strftime("%d/%m/%Y"),
          p.created_at&.strftime("%d/%m/%Y %H:%M")
        ]
      end
    end
    xlsx.to_stream.read
  end

  def generate_diligences_xlsx
    xlsx = Axlsx::Package.new
    wb = xlsx.workbook
    wb.add_worksheet(name: "Diligências") do |sheet|
      sheet.add_row [ "Tipo", "Descrição", "Estado", "Responsável", "Data Prevista", "Data Real" ]
      @diligences.each do |d|
        sheet.add_row [
          d.diligencia_type&.name,
          d.descricao,
          d.estado,
          d.responsavel&.full_name,
          d.data_prevista&.strftime("%d/%m/%Y"),
          d.data_real&.strftime("%d/%m/%Y")
        ]
      end
    end
    xlsx.to_stream.read
  end

  def generate_mandates_xlsx
    xlsx = Axlsx::Package.new
    wb = xlsx.workbook
    wb.add_worksheet(name: "Mandados") do |sheet|
      sheet.add_row [ "Tipo", "Destino", "Descrição", "Estado", "Emissor", "Data Emissão", "Data Prazo" ]
      @mandates.each do |m|
        sheet.add_row [
          m.mandate_type,
          m.destino,
          m.descricao,
          m.estado,
          m.emissor&.full_name,
          m.data_emissao&.strftime("%d/%m/%Y"),
          m.data_prazo&.strftime("%d/%m/%Y")
        ]
      end
    end
    xlsx.to_stream.read
  end

  def generate_evidences_xlsx
    xlsx = Axlsx::Package.new
    wb = xlsx.workbook
    wb.add_worksheet(name: "Evidências") do |sheet|
      sheet.add_row [ "Tipo", "Descrição", "Processo", "Coletor", "Data Coleta" ]
      @evidences.each do |e|
        sheet.add_row [
          e.evidence_type,
          e.descricao,
          e.process&.numero,
          e.collector&.full_name,
          e.collected_at&.strftime("%d/%m/%Y")
        ]
      end
    end
    xlsx.to_stream.read
  end
end
