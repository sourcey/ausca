require 'twitter'
require 'json'

module Ausca
  module Twitter

    # Twitter bot for gaining followers by following, favouriting and retweeting
    # targeted users and content.
    #
    # TODO: Unfollow users after a few days if no followback
    class Bot
      def options
        @options ||= {
          :consumer_key => nil,
          :consumer_secret => nil,
          :access_token => nil,
          :access_token_secret => nil,
          :config => nil,
          :config_filename => "config.json",
          :search => "#popular -rt",
          :freind_follower_ratio => 0.75,
          :retweet_min_follower_count => 100,
          :want_num_retweets => 1,
          :want_num_favorites => 5,
          :max_loops => 5
        }
      end

      def initialize(opts)
        options.merge!(opts)
        load_config
      end

      # Create the Twitter REST client instance
      def client
        @client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = options[:consumer_key]
          config.consumer_secret     = options[:consumer_secret]
          config.access_token        = options[:access_token]
          config.access_token_secret = options[:access_token_secret]
        end
      end

      # Load the config file if a filename option was provided
      def load_config
        # Load from options or file
        @config = options[:config]
        @config ||= (JSON.parse(IO.read(
              File.expand_path(options[:config_filename],
                File.dirname(__FILE__)))) rescue {}) if options[:config_filename]
        @config['following'] ||= {}
      end

      # Save the config file if a filename option was provided
      def save_config
        p @config.inspect
        File.open(options[:config_filename], 'w'){ |f| JSON.dump(@config, f) } if options[:config_filename]
      end

      # Run the bot action
      def run
        num_retweets = 0
        num_favorites = 0
        num_loops = 0
        filters = { max_id: nil }

        # Loop until we have reached our target number of follows, retweets and favs,
        # or hit the max number of loops
        while num_loops < options[:max_loops] &&
            (num_retweets < options[:want_num_retweets] ||
              num_favorites < options[:want_num_favorites])
          num_loops += 1
          p "*** Looping #{num_loops}"

          # @option options [String] :geocode Returns tweets by users located within a given radius of the given latitude/longitude. The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by "latitude,longitude,radius", where radius units must be specified as either "mi" (miles) or "km" (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly.
          # @option options [String] :lang Restricts tweets to the given language, given by an ISO 639-1 code.
          # @option options [String] :locale Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific clients and the default should work in the majority of cases.
          # @option options [String] :result_type Specifies what type of search results you would prefer to receive. Options are "mixed", "recent", and "popular". The current default is "mixed."
          # @option options [Integer] :count The number of tweets to return per page, up to a maximum of 100.
          # @option options [String] :until Optional. Returns tweets generated before the given date. Date should be formatted as YYYY-MM-DD.
          # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available.
          # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
          # @option options [Boolean, String, Integer] :include_entities The tweet entities node will be disincluded when set to false.
          client.search(options[:search], filters).each do |tweet|
            filters[:max_id] = tweet.id
            
            #p "*** Looping #{tweet.text}"

            # Skip dead tweets
            next if tweet.lang != 'en'

            # Skip dead tweets
            next if tweet.retweet_count == 0 || tweet.favorite_count == 0

            # Skip unpopular or overpopular tweets
            next if tweet.retweet_count < 3 || tweet.retweet_count > 100#0

            # Skip tweets we have interacted with
            #next if tweet.retweeted || tweet.favorited
   
            # Skip users that aren't easy marks
            next if tweet.user.friends_count < (tweet.user.followers_count * options[:freind_follower_ratio])

            # Skip if already following
            next if @config['following'].has_key? tweet.user.id

            # Retweet the first most suitable tweet, and follow that user
            if num_retweets < options[:want_num_retweets] &&
                tweet.retweet_count > tweet.favorite_count &&

                # Ensure min followers count is met before we retweet
                tweet.user.followers_count > options[:retweet_min_follower_count]

              p "*** DO RT"
              print_tweet tweet

              begin
                @config['following'][tweet.user.id] = Time.now.utc
                client.follow!(tweet.user)
                client.retweet!(tweet)
                num_retweets += 1
              rescue => e
                p "*** RT ERROR: #{e}"
              ensure
              end
              next
            end

            # Favourite the first most suitable tweet, and follow that user
            if num_favorites < options[:want_num_favorites] #&& tweet.favorite_count > tweet.retweet_count
              p "*** DO FAV"
              print_tweet tweet

              begin
                @config['following'][tweet.user.id] = Time.now.utc
                client.follow!(tweet.user)
                client.favorite!(tweet)
                num_favorites += 1
              rescue => e
                p "*** FAV ERROR: #{e}"
              ensure
              end
              next
            end
          end
        end

    #    # Loop followed users and unfollow if no followback after 5 days
    #    now = Time.now
    #    days = 5
    #    p @config.inspect
    #    @config['following'].each do |id,time|
    #      expired = (Time.parse(time) + (60 * 60 * 24 * days)) < now
    #      if expired
    #        # TODO
    #        # check if following us
    #        # => - remove entry if true
    #        # => - remove firend and entry if false
    #      end
    #    end

        save_config
      end

      # Print useful information about a tweet
      def print_tweet tweet
        puts "---------------------------------------"
        puts tweet.text
        puts "favorite_count: #{tweet.favorite_count}"
        puts "retweet_count: #{tweet.retweet_count}"
        puts "retweeted #{tweet.retweeted}"
        puts "favorited #{tweet.favorited}"
        puts "source #{tweet.source}"
        puts "lang #{tweet.lang}"
        puts "user friends #{tweet.user.friends_count}"
        puts "user followers #{tweet.user.followers_count}"
      end
    end
  end
end