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
    when "notice"
      'fb-alert fb-alert-success'
    when "alert"
      'fb-alert fb-alert-error'
    when "warning"
      'fb-alert fb-alert-warning'
    else
      'fb-alert fb-alert-info'
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

  # State badges
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
      "emitido" => "blue",
      "em_andamento" => "yellow",
      "executado" => "green",
      "cancelado" => "gray"
    }
    color = colors[estado&.downcase]&.to_s || "gray"
    label = case estado
            when "agendada" then "Agendada"
            when "em_andamento" then "Em Andamento"
            when "concluida" then "Concluída"
            when "cancelada" then "Cancelada"
            when "emitido" then "Emitido"
            when "executado" then "Executado"
            when "cancelado" then "Cancelado"
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
      "archived" => "gray"
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

  # Breadcrumb helper
  def breadcrumb(items)
    content_tag(:nav, class: "fb-breadcrumb mb-4") do
      items.each_with_index.map do |item, index|
        if index == items.length - 1
          content_tag(:span, class: "fb-breadcrumb-current") { item[:text] }
        else
          [
            link_to(item[:text], item[:url], class: "fb-breadcrumb-link"),
            content_tag(:span, "›", class: "fb-breadcrumb-separator")
          ].compact.join.html_safe
        end
      end.join.html_safe
    end
  end

  # Empty state helper
  def empty_state(title, description, action_text = nil, action_path = nil)
    content_tag(:div, class: "fb-empty") do
      concat(content_tag(:svg, class: "fb-empty-icon", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
        concat(%Q{<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>})
      end)
      concat(content_tag(:p, title, class: "fb-empty-title"))
      concat(content_tag(:p, description, class: "fb-empty-description")) if description
      concat(content_tag(:div, class: "mt-4") do
        link_to(action_text, action_path, class: "fb-btn fb-btn-primary") if action_text && action_path
      end)
    end
  end

  # Pagination helper with Flowbite styles
  def pagination_links(paginated_collection)
    return unless paginated_collection.total_pages > 1
    
    content_tag(:div, class: "flex items-center justify-between border-t border-slate-200 px-4 py-3") do
      concat(content_tag(:p, class: "text-sm text-slate-700") do
        "Mostrando #{paginated_collection.offset + 1} a #{[paginated_collection.offset + paginated_collection.limit, paginated_collection.total].min} de #{paginated_collection.total} resultados"
      end)
      concat paginate_links(paginated_collection)
    end
  end
end
