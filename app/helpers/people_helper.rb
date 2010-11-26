module PeopleHelper  
  def background_blank?( profile )
    profile.background_blank? and @credentials.empty? and @affiliations.empty? and @positions.empty?
  end          
end
