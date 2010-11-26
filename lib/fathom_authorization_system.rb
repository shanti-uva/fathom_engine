module FathomAuthorizationSystem
  
  def content_author?( content )
    ( logged_in? and content.user and content.user.id == current_user.id )
  end

  def full_access?()
    ( logged_in? && ( current_user.access_level == 'Full' || current_user.access_level == 'Admin' || current_user.access_level == 'Root' ) )
  end
   
  def has_requested_access?()
    current_user.request_full
  end

  def upgrade_to_full_access()
    if current_user.access_level == 'Guest'
      current_user.access_level = 'Full'
    end
  end
   
  def admin?()
    ( logged_in? && (current_user.access_level == 'Admin' || current_user.access_level == 'Root' ) )
  end

  def root?()
    ( logged_in? && current_user.access_level == 'Root' )
  end

  def full_access_project_member?(project)
    ( full_access? && current_user.person.projects.include?(project) )
  end

  def full_access_tool_member?(tool)
    ( full_access? && current_user.person.tools.include?(tool) )
  end

  def full_access_organization_member?(organization)
    ( full_access? && current_user.person.organizations.include?(organization) )
  end
   
  def allowed_to_edit?(entity)
    return false if !logged_in?

    # FUTURE: This should be part of an Entity mixin.
    case entity[:type]
    when "Person"
      content_author?(entity) || admin?
    when "Project"
      full_access_project_member?(entity)
    when "Tool"
      full_access_tool_member?(entity)
    when "Organization"
      full_access_organization_member?(entity)
    end
  end

  def allowed_to_delete?(entity)
    # FUTURE: This should be part of an Entity mixin.
    case entity[:type]
      when "Person"
        logged_in? && current_user.person.id == entity.id
      else false
    end
  end
  
  def private_user?()
    current_user.private_profile
  end
end