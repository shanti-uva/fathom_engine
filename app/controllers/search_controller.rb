require 'wordpress_indexer'

class SearchController < ApplicationController
  
  #layout 'main' 
  before_filter :main_nav
    
  def index
    #To handle home search params with type_facet
    if !params[:f].blank?
      if params[:f].is_a?(Hash)
        if !params[:f][:type_facet].blank?
          if !params[:f][:type_facet][0].blank?
            if params[:f][:type_facet][0] == "All"
              #params[:f].delete("type_facet")
              params.delete("f")
            end
          end    
        end
      end  
    end
    
    # TODO: This should really be a configurable value, not a hard-coded limit.
    page_size = params[:per_page] == nil ? 30 : params[:per_page].to_i
    current_page = params[:page] == nil || params[:page].to_i < 1 ?
      1 : params[:page].to_i

    @search_query = params[:s].to_s
    
    @solr = SolrSearch.new( SOLR_URL )
    @current_nav_item = :search
    
    @facet_fields = ['type_facet']
    ProfileTagCombiner::TAG_FIELDS.each do |tag|
      @facet_fields << "#{tag}_facet"
    end
    
    solr_params = {:facets=>{:fields=>@facet_fields, :mincount=>1}}
    
    # Parameterize search query on the search type.
    if params[:stype]=='name'
      solr_params[:query_fields] = 'name_t' # for doing name searches (not keyword)
    end

    solr_params[:filter_queries] = []

    type_facet_present = false
    if params[:f] and params[:f].is_a?(Hash)
      params[:f].each do |field,values|
        values.each do |v|
          next if v.to_s.empty?
          type_facet_present = true if field == 'type_facet'
          solr_params[:filter_queries] << "#{field}:\"#{v}\""
        end
      end
    end

    facet_filter_query = solr_params[:filter_queries].dup

    # Make a query on entities if:
    # 1.) At least one facet was selected that is a type facet; or
    # 2.) Both of the following:
    #   a.) No facets were selected; and
    #   b.) A search term was not entered.
    if (type_facet_present || (solr_params[:filter_queries].size == 0 &&
          @search_query == nil))
      # solr_params[:filter_queries] << "docType:\"#{SearchResult::ENTITY_TYPE}\""
    end

    # 'and' all the filter terms together into a single Solr query.
    # Effectively transforms an array with contents of ["a", "b", "c"] into "+a +b +c".
    solr_params[:filter_queries] = solr_params[:filter_queries].map { |e| "+#{e}" }.join(" ")
    doctype_filter_query = " +(docType:\"#{SearchResult::ENTITY_TYPE}\" docType:\"#{SearchResult::EXTERNAL_TYPE}\")"
    solr_params[:filter_queries] << doctype_filter_query

    # Fetch as many records from Solr as the size of a single page.
    solr_params[:rows] = page_size

    # If we need to start looking from somewhere other than the beginning, we
    # can specify this to Solr with the :start parameter.
    if (current_page > 1)
      # The first record we want to fetch is the ((page - 1)*page_size)th record.
      solr_params[:start] = (current_page - 1) * (page_size)
    end

    begin
      #if @search_query.blank?
      #  @solr_result_set = @solr.search("*:*", solr_params)
      #else
        @solr_result_set = @solr.search(@search_query, solr_params)
      #end

    rescue Exception => e 
     #ExceptionNotifier.deliver_exception_notification(e, self, request)
    end
   
    @search_results = @solr_result_set.hits.map do |r|
      result = SearchResult.new(r)
      # TODO: Optimization: don't perform secondary search if we're not really
      # searching and we're just getting facet counts.

      # Search for fragments with the same entity ID.
      # TODO: Requires N queries (up to page_size). Is there a better way?
      # We can't one-shot this either because of the paging/grouping
      # mechanic. An Ajax reload would make it on-demand, though.

      unless (!params[:f].nil? && params[:f].size == 1 && type_facet_present)
        # If we're only looking for a type, don't bother doing a subquery since we'd have to retrieve all fragments.
        sqp = solr_params
        sqp[:filter_queries] = facet_filter_query.dup
        sqp[:filter_queries] << "docType:\"#{SearchResult::FRAGMENT_TYPE}\""
        sqp[:filter_queries] << "entityID:#{r['entityID']}"
        sqp[:filter_queries] = sqp[:filter_queries].map {|e| "+#{e}"}.join(" ")

        # Make a new connection.
        # TODO: This seems suboptimal. Can we avoid making a new search every time?
        # This'd be possible if Solr had something like "SELECT .. WHERE ..".
        result.associated_records = @solr.search(@search_query, sqp).hits.map do |s|
          SearchResult.new(s)
        end
      end

      result
    end if @solr_result_set

    if @solr_result_set  #Make sure that @solr_result_set is not null
      # Make the total number of results available to the view.
      @results_size = @solr_result_set.data['response']['numFound']

      # Create a new WillPaginate::Collection to hold the records to be
      #   paginated, with associated metadata about the pages.
      @search_results = WillPaginate::Collection.create(current_page,
        page_size, @results_size) do |i|
        i.replace(@search_results)
      end
    else
      @results_size = 0  
    end
  end

  def regenerate_index
    # Only administrators can regenerate the index.
    unless admin?
      access_denied
      return
    end
    
    #rss_feed = URI.parse(unguarded_link('/wordpress/?feed=rss2'))
    # gotta be localhost for the balancer to resolve
    #rss_feed.host='127.0.0.1'
    # now set the host name...
    #feed=open(rss_feed.to_s, 'Host'=>request.env['SERVER_NAME'])
    
    begin # We want to be able to index even if the wordpress stuff isn't installed.
      feed = open("http://" + request.env['SERVER_NAME'] + '/wordpress/?feed=rss2')
      
      wpi = WordPressIndexer.new(SolrSearch.new(SOLR_URL), feed)
      wp_total=wpi.go! do |data|
        {
          :text=>[data[:item].title,data[:item].description],
          :displayText=>data[:item].description,
          :postTitle=>data[:item].title,
          :urlPath=>data[:path],
          :docType=> SearchResult::EXTERNAL_TYPE,
          :id=>"wordpress_#{data[:post_id]}"
        }
      end
    rescue
      wp_total = 0
    end
      
    @current_nav_item = :search
    
    solr = SolrSearch.new( SOLR_URL )

    @entities = {}
    # For each kind of entity we want to index...
    Entity::INDEXED_TYPES.each do |kind|
      # ... find all records of that kind...
      @entities[kind] = kind.classify.constantize.find(:all).each { |e|
        # ... then index them.
        e.index(solr, :no_commit)
      }
    end

    # Count the number of records we indexed.
    entity_total = @entities.inject(0) { |sum, (k, v)| sum + v.size }
    
    # Count the total number of records.
    @records_indexed = wp_total + entity_total

    # Push to Solr.
    solr.commit
  end
  
  protected
  def main_nav
    @current_nav_item = :search
    @login_enabled = true
    @nav_enabled = true
    @profile_view = true    
  end
end
