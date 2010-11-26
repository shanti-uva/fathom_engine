require 'rss/2.0'
require 'open-uri'
require 'uri'

class WordPressIndexer
  
  attr_accessor :solr
  attr_accessor :wp_rss_feed
  
  def initialize(solr, wp_rss_feed)
    self.solr=solr
    self.wp_rss_feed=wp_rss_feed
  end
  
  def go!(commit=true, &block)
    raise 'Block must be given for generating Solr doc/hash' unless block_given?
    items=fetch_rss(self.wp_rss_feed)
    items.each do |item|
      uri=URI.parse(item.link)
      # join the path and query string
      path=[uri.path, uri.query].join('?')
      post_id=uri.query.scan(/\?p=(\d+)/)[0].to_s
      self.solr.add_document yield(:item=>item,:path=>path,:post_id=>post_id)
    end
    self.solr.commit if commit
    items.size
  end
  
  #
  #
  #
  def fetch_rss(string_io, length=2, perform_validation=false)
    posts = []
    string_io.each do |rss|
      posts = RSS::Parser.parse(rss, perform_validation).items rescue []
    end
    posts.size > length ? posts[0..length - 1] : posts
  end
  
end