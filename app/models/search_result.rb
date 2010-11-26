class SearchResult
  require "erb"
  include ERB::Util
    
  attr_accessor :id, :doc_type, :url_path, :post_title, :hit_url, :hit_name, :entity_url,
    :entity_image_url, :entity_name, :text, :associated_records, :entity_last_updated_on, :entity_title
  
  MAX_TEXT_LENGTH = 200
  FRAGMENT_TYPE = :fragment
  ENTITY_TYPE = :entity
  EXTERNAL_TYPE = :external
  
  def initialize( result )
    @id = result[:id]
    if result['displayText'].length > MAX_TEXT_LENGTH 
      @text = "#{result['displayText'].slice(0,MAX_TEXT_LENGTH)}..."
    else
      @text = result['displayText']
    end
    # call the setup method for the docType value:
    # TODO: Dispatching on name is a code smell. Need to fix this; a new class for each
    # kind of search result is an appropriate strategy.

    target = nil
    case result['docType'].to_sym
    when FRAGMENT_TYPE then target = :setup_fragment!
    when ENTITY_TYPE then target = :setup_entity!
    when EXTERNAL_TYPE then target = :setup_external!
    end

    send(target, result) if target
  end
  
  # FIXME: This doesn't seem to be used anywhere.
  def self.search( solr, query, opts={} )
    results = solr.query( query, opts )
    results.hits.map { |result|
      SearchResult.new( result )
    } if results
  end
  
  protected
  
  #
  # Setup this instance as an Entity (probably should be a new class type; SearchResult::Entity ?)
  # TODO: Likely a new class, SearchResult::Fragment.
  def setup_fragment!(result)
    @doc_type = FRAGMENT_TYPE

    # Look up the controller from the entityType.
    controller = controllerize result['entityType']
    @hit_url = "/#{controller}/#{result['entityID']}?tab=#{result['fieldSet'].downcase}"
    @hit_name = "#{result['fieldSet']} &raquo; #{result['fieldName']}"
    @fragment_name = "#{result['entityName']} &raquo; " + @hit_name
    @entity_url = "/#{controller}/#{result['entityID']}"
    @entity_image_url = result['imageURL']
    @entity_name = result['entityName']
  end
  
  # TODO: Likely a new class, SearchResult::External.
  def setup_external!(result)
    @doc_type = EXTERNAL_TYPE
    @post_title=result['postTitle']
    @url_path=result['urlPath']
  end

  def setup_entity!(result)
    c = controllerize result['entityType']
    
    @doc_type = ENTITY_TYPE
    @hit_name = result['entityName']
    @entity_url = "/#{c}/#{result['entityID']}"
    @entity_image_url = result['imageURL']
    @associated_records = []

    e = Entity.find(result['entityID'])
    @entity_last_updated_on = !e.nil? ? e.last_updated_on : nil

    if (result['entityType'].downcase == :person.to_s)
      p = Person.find(result['entityID'])
      @entity_title = !p.nil? ? h(p.person_profile.title) : nil
    end
  end

  #
  # Transforms the name of an entity into the name of its corresponding controller.
  def controllerize(s)
    s.pluralize.downcase
  end
end