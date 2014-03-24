require_relative "../lib/ausca"

rss = Ausca::RSS::Combiner.new({
  :feeds => 
    # http://www.topix.com/rss/popular/topstories
    # http://feeds.bbci.co.uk/news/rss.xml
    # http://www.nasa.gov/rss/lg_image_of_the_day.rss
    [ "http://www.topix.com/rss/popular/topstories", "http://feeds.bbci.co.uk/news/rss.xml" ],
  :max_items => 50,
  :output_path => "feed.rss",
  
  # RSS variables
  :version => "2.0",
  :title => "test title",
  :description => "test description",
  :link => "test link",
  :author => "test author"
  
})
rss.generate