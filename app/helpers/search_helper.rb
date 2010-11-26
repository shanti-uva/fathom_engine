module SearchHelper
  
  def facet_in_params?(field, value)
    params[:f] and params[:f][field] and params[:f][field].include?(value)
  end
  
  def params_for_adding_facet(field, value)
    p = params.dup
    p[:f] ||= {}
    p[:f][field] ||= []
    p[:f][field] << value
    p
  end
  
  def params_for_removing_facet(field, value)
    return params unless facet_in_params?(field, value)
    p = params.dup
    p[:f][field].delete_if{|v| v==value }
    p[:f].delete(field) if p[:f][field].size==0
    p
  end

  def render_result_size(result_kind)
    list = @entities[result_kind]
    return if list.empty?
    content_tag(:li, "#{list.size} #{result_kind}")
  end
end