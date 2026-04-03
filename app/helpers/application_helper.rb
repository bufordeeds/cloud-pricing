module ApplicationHelper
  include Pagy::Frontend

  def sort_link(label, field, current_sort, current_direction)
    active = current_sort == field.to_s
    new_direction = active && current_direction == "asc" ? "desc" : "asc"
    arrow = if active
      current_direction == "asc" ? " ↑" : " ↓"
    else
      ""
    end

    link_to(
      "#{label}#{arrow}".html_safe,
      instances_path(sort_params.merge(sort: field, direction: new_direction)),
      class: "hover:text-blue-600 #{active ? 'text-blue-600 font-semibold' : 'text-gray-600'}",
      data: { turbo_frame: "instances" }
    )
  end

  def sort_params
    params.permit(:providers, :vcpus_min, :vcpus_max, :memory_min, :memory_max, :family, :q, :sort, :direction, providers: []).to_h
  end

  def format_price(price)
    "$#{sprintf('%.4f', price)}"
  end

  def format_monthly(price)
    "$#{sprintf('%.2f', price * 730)}"
  end

  def provider_badge(provider)
    tag.span(
      provider.name,
      class: "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium text-white",
      style: "background-color: #{provider.color}"
    )
  end

  def llm_provider_badge(provider)
    provider_badge(provider)
  end

  def llm_sort_link(label, field, current_sort, current_direction)
    active = current_sort == field.to_s
    new_direction = active && current_direction == "asc" ? "desc" : "asc"
    arrow = if active
      current_direction == "asc" ? " ↑" : " ↓"
    else
      ""
    end

    link_to(
      "#{label}#{arrow}".html_safe,
      llm_models_path(llm_sort_params.merge(sort: field, direction: new_direction)),
      class: "hover:text-blue-600 #{active ? 'text-blue-600 font-semibold' : 'text-gray-600'}",
      data: { turbo_frame: "llm-models" }
    )
  end

  def llm_sort_params
    params.permit(:context_min, :context_max, :q, :sort, :direction, providers: []).to_h
  end

  def format_token_price(price)
    "$#{sprintf('%.2f', price)}"
  end

  def format_context_window(context_k)
    return "—" if context_k.nil?
    if context_k >= 1000
      "#{context_k / 1000}M"
    else
      "#{context_k}k"
    end
  end

  def capability_badges(model)
    model.capabilities.map do |cap|
      color = case cap
      when "Vision" then "bg-purple-100 text-purple-800"
      when "Tools" then "bg-green-100 text-green-800"
      when "Thinking" then "bg-amber-100 text-amber-800"
      end
      tag.span(cap, class: "inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium #{color} mr-1")
    end.join.html_safe
  end
end
