require_relative "../lib/ausca"

# Instantiate the bot
bot = Ausca::Twitter::Bot.new({
  :consumer_key => "TWITTER_API_KEY",
  :consumer_secret => "TWITTER_API_SECRET",
  :access_token => "TWITTER_ACCESS_TOKEN",
  :access_token_secret => "TWITTER_ACCESS_SECRET",
  :search => "#awesome -rt",
  :want_num_retweets => 1,
  :want_num_favorites => 3
})

# Run the bot once
bot.run