class SubsiteSearch
  
  def self.get_search_param
    return @search_param
  end
  
  def self.set_search_param(forced_param)
    @search_param = forced_param
    @sub_site_search_initialized = true
  end
  
  def self.sub_site_search_initialized?
    return @sub_site_search_initialized
  end
end