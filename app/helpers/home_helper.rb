module HomeHelper

  # return only 60 characters and ... afterwards
  def carousel_featured_title( title )
    
    if not title.empty?
      if title.length > 60
        return title.to(60) + '...'
      else
        return title
      end
    end
	end
	
	# return only 264 characters and ... afterwards
  def carousel_featured_overview( overview )
    if not overview.nil?
      if not overview.empty?
        if overview.length > 264
          return (overview.to(264) + '...').html_safe
        else
          return overview.html_safe
        end
      end
    end
	end
end
