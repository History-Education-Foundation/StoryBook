module ApplicationHelper
  def active_link_class(path, active_class: "border-indigo-500 text-gray-900", inactive_class: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    current_page?(path) ? active_class : inactive_class
  end

  def active_mobile_link_class(path, active_class: "border-indigo-500 bg-indigo-50 text-indigo-700", inactive_class: "border-transparent text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700")
    current_page?(path) ? active_class : inactive_class
  end
end
