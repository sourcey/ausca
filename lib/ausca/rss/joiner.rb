require 'nokogiri'
require 'open-uri'

module Ausca
  module RSS
    class Joiner
      def options
        @options ||= {
          # Array of source feed URLs to join
          feeds: [],
          
          # Max output feed items
          max_items: 20,
          
          # Output RSS file path
          output_path: "feed.rss",
          
          # RSS variables
          version: "2.0",
          title: "my title",
          description: "my description",
          link: "my link",
          author: "my author",
        }
      end

      def initialize(opts)
        options.merge!(opts)
        options[:feeds].to_a unless options[:feeds].is_a? Array 
      end    

      # Generates the output RSS feed
      def generate    
        items = self.fetch
        items = self.filter items
        
        rss = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.rss(version: options[:version]) do
            xml.channel do
              xml.title options[:title]
              xml.description options[:description]
              xml.link options[:link]
              xml.author options[:author]
                            
              items.each do |source_item|
                xml.item do
                  xml.title source_item[:title]
                  xml.description do
                    xml.cdata source_item[:description] # CGI::unescape_html 
                  end
                  xml.link source_item[:link]
                  xml.category source_item[:category] unless source_item[:category].empty?
                  xml.pubDate source_item[:pubDate].httpdate
                  
                  # optional image
                  if source_item[:image]
                    xml.image do
                      xml.url source_item[:image]
                    end
                  end
                end
              end
            end
          end
        end
        
        self.save rss.to_xml
      end  
      
      # Fetch and combine the remote feeds
      def fetch          
        items = []
        # File.open(options[:feeds], 'r').each_line { |f| }
        options[:feeds].each { |url|
          p "Fetching: #{url}"
          open(url) do |rss|            
            doc = Nokogiri::XML(rss.read) # Nokogiri::XML::ParseOptions::NOCDATA
            doc.xpath('//item').map do |i|
              items << { 
                title: i.xpath('title').text, 
                description: i.xpath('description').text, 
                link: RSS::Util.item_source_url(i),
                image: RSS::Util.item_image_url(i), 
                category: i.xpath('category').text, 
                pubDate: Time.parse(i.xpath('pubDate').text)
              }
            end
          end        
        } 
        items.sort_by { |k| k[:pubDate] }.reverse   
      end    
       
      # Filter the output feed items based on optional constraints
      def filter items
        items = items.first(options[:max_items]) if options[:max_items] > 0
      end 
            
      def save rss
        File.write(options[:output_path], rss)
        #File.open(options[:output_path], 'w') { |f| rss }
      end   
    end
  end
end