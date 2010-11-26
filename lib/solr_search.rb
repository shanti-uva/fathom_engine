require 'solr'

class SolrSearch
  
  def initialize( url )
    @disabled = true unless url
    return if @disabled
    # connect to the solr instance
    @connection = Solr::Connection.new( url )    
  end
  
  def add_document( document )
    return if @disabled
    @connection.add( document )
  end
  
  def commit()
    return if @disabled
    @connection.commit
  end
  
  def query( query, opts={} )
    return nil if @disabled
    @connection.query(query, opts)
  end
  
  # uses dismax instead
  def search( query, opts={} )
    return nil if @disabled
    @connection.search(query, opts)
  end

  def remove_document( id )
    return if @disabled
    @connection.delete(id)  
  end
    
end