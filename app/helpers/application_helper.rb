module ApplicationHelper
  def nav_link_class(controller_name = nil, action_name = nil)
    current_controller = controller_name || params[:controller].gsub("admin/", "")
    current_action = action_name || params[:action]

    if current_controller == params[:controller].gsub("admin/", "")
      base = "sidebar-link"
      base += " sidebar-link-active" if current_action == params[:action] || (params[:action] == "index" && current_controller == params[:controller].gsub("admin/", ""))
      base
    else
      "sidebar-link"
    end
  end

  def flash_class(type)
    case type.to_s
    when "notice" then "fb-alert fb-alert-success"
    when "alert" then "fb-alert fb-alert-error"
    when "warning" then "fb-alert fb-alert-warning"
    else "fb-alert fb-alert-info"
    end
  end

  def current_profile
    current_user&.assigned_profiles&.first
  end

  def current_account
    @current_account ||= Account.find_by(id: session[:account_id])
  end

  def logged_in?
    session[:account_id].present?
  end

  def state_badge(code)
    colors = {
      "REGISTADO" => "blue",
      "EM_DISTRIBUICAO" => "yellow",
      "DISTRIBUIDO" => "green",
      "EM_INSTRUCAO" => "green",
      "DEVOLVIDO" => "red",
      "PENDENTE" => "yellow",
      "SUSPENSO" => "gray",
      "CONCLUIDO" => "blue",
      "ENCERRADO" => "gray",
      "ARQUIVADO" => "purple",
      "ANULADO" => "red"
    }
    color = colors[code]&.to_s || "gray"
    content_tag(:span, code.presence&.humanize || "—", class: "fb-badge fb-badge-#{color}")
  end

  def priority_badge(code)
    colors = {
      "NORMAL" => "gray",
      "ALTA" => "yellow",
      "URGENTE" => "red"
    }
    color = colors[code]&.to_s || "gray"
    content_tag(:span, code.presence&.humanize || "—", class: "fb-badge fb-badge-#{color}")
  end

  def estado_badge(estado)
    colors = {
      "agendada" => "blue",
      "em_andamento" => "yellow",
      "concluida" => "green",
      "cancelada" => "gray",
      "REGISTADO" => "blue",
      "EM_DISTRIBUICAO" => "yellow",
      "DISTRIBUIDO" => "green",
      "EM_INSTRUCAO" => "green",
      "DEVOLVIDO" => "red",
      "PENDENTE" => "yellow",
      "SUSPENSO" => "gray",
      "CONCLUIDO" => "blue",
      "ENCERRADO" => "gray",
      "ARQUIVADO" => "purple",
      "ANULADO" => "red"
    }
    color = colors[estado&.downcase]&.to_s || "gray"
    label = case estado
            when "agendada" then "Agendada"
            when "em_andamento" then "Em Andamento"
            when "concluida" then "Concluída"
            when "cancelada" then "Cancelada"
            else estado.presence&.humanize || "—"
            end
    content_tag(:span, label, class: "fb-badge fb-badge-#{color}")
  end

  def status_badge(status)
    colors = {
      "draft" => "gray",
      "submitted" => "blue",
      "approved" => "green",
      "signed" => "purple",
      "archived" => "gray",
      "agendada" => "blue",
      "em_andamento" => "yellow",
      "concluida" => "green",
      "cancelada" => "red"
    }
    color = colors[status&.downcase]&.to_s || "gray"
    label = case status
            when "draft" then "Rascunho"
            when "submitted" then "Submetido"
            when "approved" then "Aprovado"
            when "signed" then "Assinado"
            when "archived" then "Arquivado"
            else status.presence&.humanize || "—"
            end
    content_tag(:span, label, class: "fb-badge fb-badge-#{color}")
  end
end
