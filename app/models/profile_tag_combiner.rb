class ProfileTagCombiner

  TAG_FIELDS = [
    :disciplines,
    :general_interests,
    :time_periods_of_interest,
    :places_of_interest,
    :technologies_of_interest,
    :languages,
    :developers,
    :producers,
    :license_types,
    :platforms,
    :operating_systems
  ]

  def initialize
    @solr = SolrSearch.new( SOLR_URL )
  end

  def facet_fields()
    return @facet_fields if @facet_fields

    fields = ['type_facet']
    ProfileTagCombiner::TAG_FIELDS.each do |facet|
      fields << "#{facet}_facet"
    end

    doctype_filter_query = " +(docType:\"#{SearchResult::ENTITY_TYPE}\" docType:\"#{SearchResult::EXTERNAL_TYPE}\")"
    solr_params = {:facets=>{:fields=>fields, :mincount=>1, :limit=>-1 }, :filter_queries => [ doctype_filter_query ] }
    solr_result_set = @solr.search("", solr_params)
    #solr_result_set = @solr.search("*:*", solr_params)
    

    @facet_fields = solr_result_set.data['facet_counts']['facet_fields']
  end

  def tag_counts( facet )
    facets = facet_fields["#{facet.to_s}_facet"]
    counts = {}
    i=0
    while i < facets.size
      tag = facets[i]
      count = facets[i+1]
      counts[tag] = count
      i = i + 2
    end
    counts
  end

end