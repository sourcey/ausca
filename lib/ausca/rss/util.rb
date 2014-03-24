module Ausca
  module RSS
    class Util 
      class << self
      
        # Get the source URL for an RSS item
        def item_source_url node
          url = node.at_xpath('source').attr('url') if node.at_xpath('source')
          url = (node.xpath('link').text if node.at_xpath('link')) unless url         
          url
        end        

        # Get an image from the image or content element
        def item_image_url item
          url = i.at_xpath('media|thumbnail').attr('url') if i.at_xpath('media|thumbnail') rescue nil
          url = i.at_xpath('enclosure').attr('url') unless url rescue nil
          #url = item.content.to_s[/img.*?src=\\\"(.*?)\\\"/i,1] unless url rescue nil
          url 
        end
        
        def default_text item
          s = "#{item[:title]} #{item[:link]}"
          s += " ##{item[:category].gsub(/\s+/, "").downcase}" if item[:category]
          CGI::unescape_html s #.html_safe
        end

        def default_text_with_description item
          s = "#{item[:title]}: #{item[:description]} #{item[:link]}"
          s += " ##{item[:category].gsub(/\s+/, "").downcase}" if item[:category]
          CGI::unescape_html s #.html_safe
        end

      end
    end
  end
end
