require 'fathom_authorization_system'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include FathomAuthorizationSystem
  
  def stylesheet_files
    if APPLICATION_DOMAIN == 'shanti.virginia.edu'
      #['fathom', 'jquery-ui','jquery.autocomplete', 'jquery.checktree', 'jquery.draggable.popup'] + super
      ['fathom', 'jquery-ui'] + super
    else #'thlib.org'
      if @current_style == :details
        super + ['fathom','thickbox','communications', 'jquery-ui-tabs', 'jquery-ui'] 
      else
        super + ['fathom','communications', 'jquery-ui-tabs', 'jquery-ui', 'Hypertreebase', 'Hypertree']
      end
    end
  end
  
  def javascript_files
    if @current_style == :home
      if APPLICATION_DOMAIN == 'shanti.virginia.edu'
        if logged_in?
          super + ['togglesections','jquery.jcarousel','thickbox-compressed','jquery-plugins','load-latest-news']
        else
          super + ['jquery.jcarousel','thickbox-compressed','jquery-plugins','load-latest-news']
        end
      else #'thlib.org'
        #super + ['jquery.jcarousel','jquery-plugins'] #neither news or toggle action is used on connections
        ['min/jquery.jcarousel'] #jquery loaded from thl template
      end
    else
      if @current_style == :details
        if APPLICATION_DOMAIN == 'shanti.virginia.edu'
          if logged_in?
            ##['category_selector','application','togglesections','thickbox-compressed','jquery-plugins','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min'] + super
            #super + ['category_selector','application','togglesections','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
            super + ['jquery.autocomplete', 'jquery.checktree', 'model-searcher', 'jquery.draggable.popup','application','togglesections','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
          else
            super + ['category_selector','application','thickbox-compressed','jquery-plugins','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
          end
        else  #'thlib.org'
          if logged_in?
            #super + ['category_selector','application','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
            super + ['category_selector','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min'] #jquery loaded from thl template
          else
            #super + ['category_selector','application','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
            super + ['category_selector','thickbox-compressed','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min'] #jquery loaded from thl template
          end          
        end
      else
        if @current_style == :showview
          if APPLICATION_DOMAIN == 'shanti.virginia.edu'
            if logged_in?
              super + ['category_selector','application','togglesections','thickbox-compressed','jquery-plugins','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
            else
              super + ['category_selector','application','thickbox-compressed','jquery-plugins','encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min']
            end
          else  #'thlib.org'
            if logged_in?
              ['encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min'] #jquery loaded from thl template
            else
              ['encodemailto','profile-detail-view','yahoo-dom-event','element-beta-min','tabview-min'] #jquery loaded from thl template
            end          
          end
        else
          if APPLICATION_DOMAIN == 'shanti.virginia.edu'
            if logged_in?
              super + ['category_selector','application','togglesections','thickbox-compressed','jquery-plugins','encodemailto']
            else
              super + ['category_selector','application','thickbox-compressed','jquery-plugins','encodemailto']
            end
          else
            if logged_in?
              if params[:inline]
                ['jquery','jrails'] + ['encodemailto'] #jquery loaded locally since modal window loads no template
              else
                ['jrails'] + ['encodemailto','jit'] #jquery loaded from thl template
              end
            else
              if params[:inline]
                ['jquery','jrails'] + ['encodemailto'] #jquery loaded locally since modal window loads no template
              else
                ['jrails'] + ['encodemailto', 'jit'] #jquery loaded from thl template
              end
            end
          end
        end 
      end
    end
  end
    
  def javascripts
    if APPLICATION_DOMAIN == 'shanti.virginia.edu'
      [super, include_tiny_mce_if_needed].join("\n").html_safe
    else #'thlib.org'
      if @current_style == :details #edit mode then needs tiny_mce
        #Commented - on May 21, 2013 - temporary removal of tinymce
        #[super, include_tiny_mce_if_needed].join("\n").html_safe
        super
      else
        super
      end
    end
  end 
  
  #Commented - on May 21, 2013 - temporary removal of tinymce 
  #def tinymce_reinitialization_script
  #  str = "<script type='text/javascript'>"+ "\n"
  #  str += "//<![CDATA[" + "\n"
  #  str += "tinyMCE.init({" + "\n"
  #  str += "editor_selector : 'mceEditor'," + "\n"
  #  str += "strict_loading_mode : tinymce.isWebKit," + "\n"
  #  str += "height : '220px'," + "\n"
  #  str += "mode : 'textareas'," + "\n"
  #  str += "relative_urls : false," + "\n"
  #  str += "noneditable_leave_contenteditable : 'true'," + "\n"
  #  str += "plugins : 'contextmenu,paste,media,fullscreen,template,noneditable, table, spellchecker'," + "\n"
  #  str += "template_external_list_url : '/templates/templates.js'," + "\n"
  #  str += "content_css : '/stylesheets/customtinymce.css'," + "\n"
  #  str += "theme : 'advanced'," + "\n"
  #  str += "theme_advanced_blockformats : 'p,h1,h2,h3,h4,h5,h6'," + "\n"
  #  str += "theme_advanced_buttons1 : ' fullscreen,separator,bold,italic,underline,strikethrough,separator,undo,redo,separator,link,unlink,template,formatselect, code'," + "\n"
  #  str += "theme_advanced_buttons2 : 'cut,copy,paste,separator,pastetext,pasteword,separator,bullist,numlist,outdent,indent,separator,justifyleft,justifycenter,justifyright,justifiyfull,separator,removeformat,charmap'," + "\n"
  #  str += "theme_advanced_buttons3 : 'spellchecker,tablecontrols '," + "\n"
  #  str += "spellchecker_languages : '+English=en'," + "\n"
  #  str += "spellchecker_rpc_url : '/application/spellchecker'," + "\n"
  #  str += "gecko_spellcheck : 'true'," + "\n"
  #  str += "table_styles : 'Header 1=header1;Header 2=header2;Header 3=header3'," + "\n"
  #  str += "table_cell_styles : 'Header 1=header1;Header 2=header2;Header 3=header3;Table Cell=tableCel1'," + "\n"
  #  str += "table_row_styles : 'Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1'," + "\n"
  #  str += "theme_advanced_resizing : 'true'," + "\n"
  #  str += "theme_advanced_toolbar_align : 'left'," + "\n"
  #  str += "theme_advanced_toolbar_location : 'top'," + "\n"
  #  str += "width : '550px'"  + "\n"
  #  str += "});" + "\n"
  #  str += "//]]>" + "\n"
  #  str += "</script> "
  #  return str.html_safe 
  #end
  
  def site_title(opts={:html=>true})
    opts[:html] ? 'SHANTI UVa' : 'SHANTI UVa' #'SHANTI at the University of Virginia' : 'SHANTI at the University of Virginia'
  end
  
  def banner_title(opts={:html=>true})
    opts[:html] ? 'SHANTI - Sciences, Humanities, and Arts Network of Technological Initiatives' : 'SHANTI - Sciences, Humanities, and Arts Network of Technological Initiatives'
  end
  
  # takes :person_profile / :profile_profile etc. for the "profile_type"
  # The "fields"  is a hash where the keys match the profiles' tag attributes (see PersonProfile etc..)
  # and the values map to HTML elements (the id attribute)
  # EXAMPLE:
  #
  #   generate_js_for_tag_autocomplete(:person_profile, {:general_interests=>'person_profile_general_interest_list'})
  #
  def generate_js_tag_jquery_ui_autocomplete(tag_combiner, profile_type, fields)
    
    js = ''
    fields.each_pair do |tag_field,tag_field_input_id|
      # list of tag values, var name prefixed by the tag field
      js << %(var #{tag_field}_profile_tags = [];\n)
      
      # Get a hash of the tags for this field
      tag_set = tag_combiner.tag_counts(tag_field)
      
      tag_set.keys.sort.each do |tag|
        js << %(#{tag_field}_profile_tags.push({value: '#{escape_javascript tag}' , label:'#{escape_javascript tag} (#{tag_set[tag].to_i})' });\n)
      end
     
    end
    js.html_safe
  end
  
  
  # takes :person_profile / :profile_profile etc. for the "profile_type"
  # The "fields"  is a hash where the keys match the profiles' tag attributes (see PersonProfile etc..)
  # and the values map to HTML elements (the id attribute)
  # EXAMPLE:
  #
  #   generate_js_for_tag_autocomplete(:person_profile, {:general_interests=>'person_profile_general_interest_list'})
  #
  def generate_js_for_tag_autocomplete(tag_combiner, profile_type, fields)
    js = ''
    fields.each_pair do |tag_field,tag_field_input_id|
      # list of tag values, var name prefixed by the tag field
      js << %(var #{tag_field}_profile_tags = [];\n)
      # the key is the tag, the value is the hit count, var name prefixed by the tag field
      js << %(var #{tag_field}_profile_tag_counts = {};\n)
      
      # Get a hash of the tags for this field
      tag_set = tag_combiner.tag_counts(tag_field)

      tag_set.keys.each do |tag|
        js << %(#{tag_field}_profile_tags.push('#{escape_javascript tag}');\n)
        js << %(#{tag_field}_profile_tag_counts['#{escape_javascript tag}'] = #{tag_set[tag].to_i};\n)
      end
      
      js << %($("##{escape_javascript tag_field_input_id}").autocomplete(#{tag_field}_profile_tags, {
      	multiple : true,
      	formatItem : function(row) {
          return row + " (" + #{tag_field}_profile_tag_counts[row] + ")";
        },
      	formatResult : function(row) {
          return row
        }
      });\n)
    end
    js.html_safe
  end
  
  def entity_profile_tag_block(tag_combiner, entity, tag_list_name, label)
    entity_name = entity.class.to_s.downcase
    # the organization model extends the project model
    # so switch back to project if the "entity" is an "organization"
    entity_name = 'project' if entity_name=='organization'
    profile_method = entity_name + '_profile'

    associated_tag_list = entity.send(profile_method).send(tag_list_name)
    complete_tag_list = tag_combiner.tag_counts(tag_list_name)

    unless associated_tag_list.empty?  
      # create the url path and :f param (facet) in the form f[FACET_FIELD][]=VALUE
        #html = "<h3>#{label}</h3>"
        html = "<dt>#{label}</dt>"
        html += "<dd>"
        html += associated_tag_list.map do |t|
          link_params = search_path({:f=>{(tag_list_name.to_s + '_facet')=>[t.name]}})
          "#{link_to(t.name.s, link_params)} <em>(#{complete_tag_list[t.name]})</em>"
        end.sort.join(', ')
        html += "</dd>"
        html.html_safe
		end
	end
  
  #
  # Convert the Textile/RedCloth input text to HTML
  #
  def rc(string)
    RedCloth.new(string).to_html
  end
  #
  # Add a 
  #
  def th(area)
    #return "<div class='textarea_wrapper'>" + area + "</div><a class='text_help_icon' onclick=\"window.open('" + compute_public_path('index.html', 'text_help', '.html') + "','mywindow','width=550,height=700, scrollbars=yes')\">?</a>"
    return area
  end
  
  def ssl_link(path)
    SSL_ENABLED ? "https://#{request.env['SERVER_NAME']}#{path}" : path
  end
  
  def ssl_stylesheet_link(stylesheet, media_type = 'screen' )
    "<link rel=\"stylesheet\" href=\"#{ssl_link('/stylesheets/'+stylesheet)}\" type=\"text/css\" media=\"#{media_type}\" />"
  end
  
  def ssl_javascript_link( javascript )
    "<script type=\"text/javascript\" src=\"#{ssl_link('/javascripts/'+javascript)}\"></script>"
  end
  	    
  def main_navigation_items()
    return @main_navigation_items if @main_navigation_items
    # basic menu options
    if APPLICATION_DOMAIN == 'shanti.virginia.edu'
      home_text_link = 'Home' #'UVa Profiles'
    else
      home_text_link = 'Connections'
    end
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      @main_navigation_items = [ 
      	{ :id => :home, :text => home_text_link, :link => home_page_path },
      	{ :id => :profile, :text => 'My Profile', :link => me_path },
      	{ :id => :people, :text => 'People', :link => people_path },
      	{ :id => :projects, :text => 'Projects', :link => projects_path },
      	{ :id => :organizations, :text => 'Organizations', :link => organizations_path },	
        { :id => :tools, :text => 'Tools', :link => tools_path },
        { :id => :posts, :text => 'Posts', :link => posts_path },
        { :id => :knowledge_base, :text => 'Knowledge Base', :link => 'https://wiki.shanti.virginia.edu/display/KB/SHANTI+Knowledge+Base' },
      	{ :id => :events, :text => 'Activities', :link => '/wordpress/?page_id=414' },
      	{ :id => :news, :text => 'News', :link => '/wordpress/?page_id=400' },
      	#{ :id => :about_us, :text => 'SHANTI Activities', :link => '/wordpress/?page_id=6' },
      ]  
      
      # don't display my profile if I am not logged in (on main navigation)
      if not logged_in?
      	my_profile = main_navigation_items.select { |item| item[:id] == :profile }.first
      	@main_navigation_items.delete(my_profile)
      end
          
    else
      @main_navigation_items = [ 
      	{ :id => :home, :text => home_text_link, :link => home_page_path },
      	{ :id => :uva_profiles, :text => "UVa Profiles", :link => people_path },
      	  #{ :id => :profile, :text => 'My Profile', :link => me_path },
      	  #{ :id => :people, :text => 'People', :link => people_path },
      	  #{ :id => :projects, :text => 'Projects', :link => projects_path },
      	  #{ :id => :organizations, :text => 'Organizations', :link => organizations_path },	
          #{ :id => :tools, :text => 'Tools', :link => tools_path },
          #{ :id => :posts, :text => 'Posts', :link => posts_path },
        { :id => :knowledge_base, :text => 'Knowledge Base', :link => 'https://wiki.shanti.virginia.edu/x/o4G' },
      	#{ :id => :community_tools, :text => 'Community Tools', :link => '/wordpress/?page_id=116' },
      	  #{ :id => :uva_profiles, :text => "UVa Profiles", :link => home_page_path },
      	{ :id => :events, :text => 'Activities', :link => '/wordpress/?page_id=414' },
      	{ :id => :news, :text => 'News', :link => '/wordpress/?page_id=400' },
      	  #{ :id => :about_us, :text => 'SHANTI Activities', :link => '/wordpress/?page_id=6' },
      ]
    end

    
    #verification, to handle different menus for shanti & thl
    if APPLICATION_DOMAIN != 'shanti.virginia.edu'
      tools = main_navigation_items.select { |item| item[:id] == :tools }.first
    	@main_navigation_items.delete(tools)
    	kbase = main_navigation_items.select { |item| item[:id] == :knowledge_base }.first
    	@main_navigation_items.delete(kbase)
    	events = main_navigation_items.select { |item| item[:id] == :events }.first
    	@main_navigation_items.delete(events)
    	news = main_navigation_items.select { |item| item[:id] == :news }.first
    	@main_navigation_items.delete(news)
    	aboutus = main_navigation_items.select { |item| item[:id] == :about_us }.first
    	@main_navigation_items.delete(aboutus)
    end    
    
    return @main_navigation_items
  end

  # Sub navigation items.
  def secondary_navigation_items()
    return @secondary_navigation_items if @secondary_navigation_items

    @secondary_navigation_items = [
    	#{ :id => :home, :text => "Profiles", :link => home_page_path },
    	{ :id => :profile, :text => 'My Profile', :link => me_path },
    	{ :id => :people, :text => 'People', :link => people_path },
    	{ :id => :projects, :text => 'Projects', :link => projects_path },
    	{ :id => :organizations, :text => 'Organizations', :link => organizations_path },	
      { :id => :tools, :text => 'Tools', :link => tools_path },
      { :id => :posts, :text => 'Posts', :link => posts_path }    	
    ]
    
    # don't display my profile if I am not logged in
    if not logged_in?
    	my_profile = secondary_navigation_items.select { |item| item[:id] == :profile }.first
    	@secondary_navigation_items.delete(my_profile)
    end
    return @secondary_navigation_items
  end
  
  # Secondary navigation items.
  def ancillary_navigation_items()
    return @ancillary_navigation_items if @ancillary_navigation_items

    @ancillary_navigation_items = [
      # FUTURE: Shanti-specific.
    	{ :id => :about_us, :text => 'SHANTI', :link => '/wordpress/?page_id=6' },
      # FUTURE: Shanti-specific.
      { :id => :resources, :text => 'Resources', :link => '/wordpress/?page_id=7' },
      # FUTURE: Shanti-specific.
    	{ :id => :news, :text => 'News', :link => '/wordpress/?page_id=4' }
    	
    ]

    return @ancillary_navigation_items
  end
  
  # Override side_column_links method that come from thl_integration plugin 
  def side_column_links
    str = "<h3 class=\"head\">#{link_to 'Communications THL', '#nogo', {:hreflang => 'Fathom Communications THL.'}}</h3>\n<ul>\n"
    str += "<li>#{link_to 'Home', root_path, {:hreflang => 'Home communications.'}}</li>\n"
    #str += "<li>#{link_to 'My Profile', me_path, {:hreflang => 'My Profile.'}}</li>\n" if logged_in?
    #str += "<li>#{link_to 'People', people_path, {:hreflang => 'Manage People'}}</li>\n"
    #str += "<li>#{link_to 'Projects', projects_path, {:hreflang => 'Manage Projects.'}}</li>\n"
    #str += "<li>#{link_to 'Organizations', organizations_path, {:hreflang => 'Manage Organizations.'}}</li>\n"
    #str += "<li>#{link_to 'Tools', tools_path, {:hreflang => 'Manage Tools.'}}</li>\n"
    str += "</ul>"
    return str
  end
  # Override flash_notice method that come from thl_integration plugin 
  def flash_notice(options = Hash.new)
    return ""
  end
  # Override language_option_links method that come from thl_integration plugin 
  def language_option_links
    return ""
  end
  #Override login_status so we don't show thl integration login status, but fathom one
  def login_status
    return ""
  end
  
  def editor_note_tip
    return '<p class="text-editor-note">NEVER paste text directly from other programs. Use the W button to paste from Word; use the T button to paste from other programs.</p>'.html_safe
  end
  
  def page_title()
    return "Search Results" if @current_nav_item == :search
    return "CONTROL PANEL" if @current_nav_item == :admin
    return "Banned Email" if @current_nav_item == :banned
    return "" if @current_nav_item == :users

    # Supply reasonable default if no current_nav_item is given.
    if @current_nav_item
      main_navigation_items.select { |item| item[:id] == @current_nav_item }.first[:text]
    else
      ''
    end
  end
  
  def simple_date( date )
    "#{date.month}/#{date.day}/#{date.year}"    
  end
  
  def collection_select_multiple(object, method,
                                   collection, value_method, text_method,
                                   options = {}, html_options = {})
      real_method = "#{method.to_s.singularize}_ids".to_sym
      collection_select(
        object, real_method,
        collection, value_method, text_method,
        options,
        html_options.merge({
          :multiple => true,
          :name => "#{object}[#{real_method}][]"
        })
      )
  end
  
  def collection_select_multiple_categories(object, method,
                                              options = {}, html_options = {})
      collection_select_multiple(
        object, method,
        Category.find(:all), :id, :title,
        options, html_options
      )
  end
  
  def join_with_and(list)
    size = list.size
    case size
    when 0 then nil
    when 1 then list.first
    when 2 then list.join(' and ')
    when 3 then [list[0..size-2].join(', '), list[size-1]].join(', and ')
    end
  end

  def entity_for_post(p)
    Entity.find(p.entity_id)
  end 
  
  def user_access_levels
     [ "Pending", "Guest", "Full", "Admin" ]
  end
  
  def disciplines
    [ "English", "Media Studies", "Computer Science", "History", "Religious Studies" ]
  end
  
  def professional_profile_options
    [ '', 'Faculty', 'Undergraduate', 'Graduate Student', 'Technologist', 'Administrator', 'Independent Scholar','Businessperson', 'Artist', 'Singer/Musician', 'Community Service Person', 'Writer']
  end
  
  def country_names
    [ 
      [ "Afghanistan", "AF" ],
      [ "Albania", "AL" ],
      [ "Algeria", "DZ" ],
      [ "American Samoa", "AS" ],
      [ "Andorra", "AD" ],
      [ "Angola", "AO" ],
      [ "Anguilla", "AI" ],
      [ "Antarctica", "AQ" ],
      [ "Antigua and Barbuda", "AG" ],
      [ "Argentina", "AR" ],
      [ "Armenia", "AM" ],
      [ "Aruba", "AW" ],
      [ "Australia", "AU" ],
      [ "Austria", "AT" ],
      [ "Azerbaijan", "AZ" ],
      [ "Bahrain", "BH" ],
      [ "Bangladesh", "BD" ],
      [ "Barbados", "BB" ],
      [ "Belarus", "BY" ],
      [ "Belgium", "BE" ],
      [ "Belize", "BZ" ],
      [ "Benin", "BJ" ],
      [ "Bermuda", "BM" ],
      [ "Bhutan", "BT" ],
      [ "Bolivia", "BO" ],
      [ "Bosnia and Herzegovina", "BA" ],
      [ "Botswana", "BW" ],
      [ "Bouvet Island", "BV" ],
      [ "Brazil", "BR" ],
      [ "British Indian Ocean Territory", "IO" ],
      [ "British Virgin Islands", "VG" ],
      [ "Brunei", "BN" ],
      [ "Bulgaria", "BG" ],
      [ "Burkina Faso", "BF" ],
      [ "Burundi", "BI" ],
      [ "Côte d'Ivoire", "CI" ],
      [ "Cambodia", "KH" ],
      [ "Cameroon", "CM" ],
      [ "Canada", "CA" ],
      [ "Cape Verde", "CV" ],
      [ "Cayman Islands", "KY" ],
      [ "Central African Republic", "CF" ],
      [ "Chad", "TD" ],
      [ "Chile", "CL" ],
      [ "China", "CN" ],
      [ "Christmas Island", "CX" ],
      [ "Cocos (Keeling) Islands", "CC" ],
      [ "Colombia", "CO" ],
      [ "Comoros", "KM" ],
      [ "Congo", "CG" ],
      [ "Cook Islands", "CK" ],
      [ "Costa Rica", "CR" ],
      [ "Croatia", "HR" ],
      [ "Cuba", "CU" ],
      [ "Cyprus", "CY" ],
      [ "Czech Republic", "CZ" ],
      [ "Democratic Republic of the Congo", "CD" ],
      [ "Denmark", "DK" ],
      [ "Djibouti", "DJ" ],
      [ "Dominica", "DM" ],
      [ "Dominican Republic", "DO" ],
      [ "East Timor", "TL" ],
      [ "Ecuador", "EC" ],
      [ "Egypt", "EG" ],
      [ "El Salvador", "SV" ],
      [ "Equatorial Guinea", "GQ" ],
      [ "Eritrea", "ER" ],
      [ "Estonia", "EE" ],
      [ "Ethiopia", "ET" ],
      [ "Faeroe Islands", "FO" ],
      [ "Falkland Islands", "FK" ],
      [ "Fiji", "FJ" ],
      [ "Finland", "FI" ],
      [ "Former Yugoslav Republic of Macedonia", "MK" ],
      [ "France", "FR" ],
      [ "French Guiana", "GF" ],
      [ "French Polynesia", "PF" ],
      [ "French Southern Territories", "TF" ],
      [ "Gabon", "GA" ],
      [ "Georgia", "GE" ],
      [ "Germany", "DE" ],
      [ "Ghana", "GH" ],
      [ "Gibraltar", "GI" ],
      [ "Greece", "GR" ],
      [ "Greenland", "GL" ],
      [ "Grenada", "GD" ],
      [ "Guadeloupe", "GP" ],
      [ "Guam", "GU" ],
      [ "Guatemala", "GT" ],
      [ "Guinea", "GN" ],
      [ "Guinea-Bissau", "GW" ],
      [ "Guyana", "GY" ],
      [ "Haiti", "HT" ],
      [ "Heard Island and McDonald Islands", "HM" ],
      [ "Honduras", "HN" ],
      [ "Hong Kong", "HK" ],
      [ "Hungary", "HU" ],
      [ "Iceland", "IS" ],
      [ "India", "IN" ],
      [ "Indonesia", "ID" ],
      [ "Iran", "IR" ],
      [ "Iraq", "IQ" ],
      [ "Ireland", "IE" ],
      [ "Israel", "IL" ],
      [ "Italy", "IT" ],
      [ "Jamaica", "JM" ],
      [ "Japan", "JP" ],
      [ "Jordan", "JO" ],
      [ "Kazakhstan", "KZ" ],
      [ "Kenya", "KE" ],
      [ "Kiribati", "KI" ],
      [ "Kuwait", "KW" ],
      [ "Kyrgyzstan", "KG" ],
      [ "Laos", "LA" ],
      [ "Latvia", "LV" ],
      [ "Lebanon", "LB" ],
      [ "Lesotho", "LS" ],
      [ "Liberia", "LR" ],
      [ "Libya", "LY" ],
      [ "Liechtenstein", "LI" ],
      [ "Lithuania", "LT" ],
      [ "Luxembourg ", "LU" ],
      [ "Macau", "MO" ],
      [ "Madagascar", "MG" ],
      [ "Malawi", "MW" ],
      [ "Malaysia", "MY" ],
      [ "Maldives", "MV" ],
      [ "Mali", "ML" ],
      [ "Malta", "MT" ],
      [ "Marshall Islands", "MH" ],
      [ "Martinique", "MQ" ],
      [ "Mauritania", "MR" ],
      [ "Mauritius", "MU" ],
      [ "Mayotte", "YT" ],
      [ "Mexico", "MX" ],
      [ "Micronesia", "FM" ],
      [ "Moldova", "MD" ],
      [ "Monaco", "MC" ],
      [ "Mongolia", "MN" ],
      [ "Montserrat", "MS" ],
      [ "Morocco", "MA" ],
      [ "Mozambique", "MZ" ],
      [ "Myanmar", "MM" ],
      [ "Namibia", "NA" ],
      [ "Nauru", "NR" ],
      [ "Nepal", "NP" ],
      [ "Netherlands", "NL" ],
      [ "Netherlands Antilles", "AN" ],
      [ "New Caledonia", "NC" ],
      [ "New Zealand", "NZ" ],
      [ "Nicaragua", "NI" ],
      [ "Niger", "NE" ],
      [ "Nigeria", "NG" ],
      [ "Niue", "NU" ],
      [ "Norfolk Island", "NF" ],
      [ "North Korea", "KP" ],
      [ "Northern Marianas", "MP" ],
      [ "Norway", "NO" ],
      [ "Oman", "OM" ],
      [ "Pakistan", "PK" ],
      [ "Palau", "PW" ],
      [ "Panama", "PA" ],
      [ "Papua New Guinea", "PG" ],
      [ "Paraguay", "PY" ],
      [ "Peru", "PE" ],
      [ "Philippines", "PH" ],
      [ "Pitcairn Islands", "PN" ],
      [ "Poland", "PL" ],
      [ "Portugal", "PT" ],
      [ "Puerto Rico", "PR" ],
      [ "Qatar", "QA" ],
      [ "Réunion", "RE" ],
      [ "Romania", "RO" ],
      [ "Russia", "RU" ],
      [ "Rwanda", "RW" ],
      [ "São Tomé and Príncipe", "ST" ],
      [ "Saint Helena", "SH" ],
      [ "Saint Kitts and Nevis", "KN" ],
      [ "Saint Lucia", "LC" ],
      [ "Saint Pierre and Miquelon", "PM" ],
      [ "Saint Vincent and the Grenadines", "VC" ],
      [ "Samoa", "WS" ],
      [ "San Marino", "SM" ],
      [ "Saudi Arabia", "SA" ],
      [ "Senegal", "SN" ],
      [ "Seychelles", "SC" ],
      [ "Sierra Leone", "SL" ],
      [ "Singapore", "SG" ],
      [ "Slovakia", "SK" ],
      [ "Slovenia", "SI" ],
      [ "Solomon Islands", "SB" ],
      [ "Somalia", "SO" ],
      [ "South Africa", "ZA" ],
      [ "South Georgia and the South Sandwich Islands", "GS" ],
      [ "South Korea", "KR" ],
      [ "Spain", "ES" ],
      [ "Sri Lanka", "LK" ],
      [ "Sudan", "SD" ],
      [ "Suriname", "SR" ],
      [ "Svalbard and Jan Mayen", "SJ" ],
      [ "Swaziland", "SZ" ],
      [ "Sweden", "SE" ],
      [ "Switzerland", "CH" ],
      [ "Syria", "SY" ],
      [ "Taiwan", "TW" ],
      [ "Tajikistan", "TJ" ],
      [ "Tanzania", "TZ" ],
      [ "Thailand", "TH" ],
      [ "The Bahamas", "BS" ],
      [ "The Gambia", "GM" ],
      [ "Togo", "TG" ],
      [ "Tokelau", "TK" ],
      [ "Tonga", "TO" ],
      [ "Trinidad and Tobago", "TT" ],
      [ "Tunisia", "TN" ],
      [ "Turkey", "TR" ],
      [ "Turkmenistan", "TM" ],
      [ "Turks and Caicos Islands", "TC" ],
      [ "Tuvalu", "TV" ],
      [ "US Virgin Islands", "VI" ],
      [ "Uganda", "UG" ],
      [ "Ukraine", "UA" ],
      [ "United Arab Emirates", "AE" ],
      [ "United Kingdom", "GB" ],
      [ "United States", "US" ],
      [ "United States Minor Outlying Islands", "UM" ],
      [ "Uruguay", "UY" ],
      [ "Uzbekistan", "UZ" ],
      [ "Vanuatu", "VU" ],
      [ "Vatican City", "VA" ],
      [ "Venezuela", "VE" ],
      [ "Vietnam", "VN" ],
      [ "Wallis and Futuna", "WF" ],
      [ "Western Sahara", "EH" ],
      [ "Yemen", "YE" ],
      [ "Yugoslavia", "YU" ],
      [ "Zambia", "ZM" ],
      [ "Zimbabwe", "ZW" ]
    ]
  end
  
  def state_names
    [
      [ "Alabama", "AL" ],
      [ "Alaska", "AK" ],
      [ "Arizona", "AZ" ],
      [ "Arkansas", "AR" ],
      [ "California", "CA" ],
      [ "Colorado", "CO" ],
      [ "Connecticut", "CT" ],
      [ "Delaware", "DE" ],
      [ "District Of Columbia", "DC" ],
      [ "Florida", "FL" ],
      [ "Georgia", "GA" ],
      [ "Hawaii", "HI" ],
      [ "Idaho", "ID" ],
      [ "Illinois", "IL" ],
      [ "Indiana", "IN" ],
      [ "Iowa", "IA" ],
      [ "Kansas", "KS" ],
      [ "Kentucky", "KY" ],
      [ "Louisiana", "LA" ],
      [ "Maine", "ME" ],
      [ "Maryland", "MD" ],
      [ "Massachusetts", "MA" ],
      [ "Michigan", "MI" ],
      [ "Minnesota", "MN" ],
      [ "Mississippi", "MS" ],
      [ "Missouri", "MO" ],
      [ "Montana", "MT" ],
      [ "Nebraska", "NE" ],
      [ "Nevada", "NV" ],
      [ "New Hampshire", "NH" ],
      [ "New Jersey", "NJ" ],
      [ "New Mexico", "NM" ],
      [ "New York", "NY" ],
      [ "North Carolina", "NC" ],
      [ "North Dakota", "ND" ],
      [ "Ohio", "OH" ],
      [ "Oklahoma", "OK" ],
      [ "Oregon", "OR" ],
      [ "Pennsylvania", "PA" ],
      [ "Rhode Island", "RI" ],
      [ "South Carolina", "SC" ],
      [ "South Dakota", "SD" ],
      [ "Tennessee", "TN" ],
      [ "Texas", "TX" ],
      [ "Utah", "UT" ],
      [ "Vermont", "VT" ],
      [ "Virginia", "VA" ],
      [ "Washington", "WA" ],
      [ "West Virginia", "WV" ],
      [ "Wisconsin", "WI" ],
      [ "Wyoming", "WY" ]
    ]
  end
  
  # create the <li> element for the specified tab
  def tab_tag( tab_id, tab_label, selected_id )
    tab_name = tab_id.to_s
    selected = tab_id == selected_id ? "class='selected'" : ""
    "<li id='#{tab_name}-tab-button' #{selected}><a href='##{tab_name}-tab'><span>#{tab_label}</span></a></li>".html_safe
	end
  
end
