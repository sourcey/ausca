---
layout: index
---

# Ausca

Ausca is a collection of automation utilities and bots written in Ruby.

## Installation

Add this line to your application's Gemfile:

```
gem 'ausca'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install ausca
```

## Usage

Check the `examples` directory for functional examples.

### RSS Joiner

Ausca has a feed combiner which enables you to generate your own RSS feeds from various different sources.

The API is very simple:

```ruby
require "ausca"

rss = Ausca::RSS::Joiner.new({
  :feeds => 
    [ "http://www.topix.com/rss/popular/topstories", "http://feeds.bbci.co.uk/news/rss.xml" ],
  :max_items => 50,
  :output_path => "feed.rss",
  :version => "2.0",
  :title => "test title",
  :description => "test description",
  :link => "test link",
  :author => "test author"  
})

# Fetch source feeds and generate the output
rss.generate
```

### Twitter Bot

The Twitter bot searches for relevent content and automatically follows people who are talking about topics of interest.

The bot can also optionally favourite and retweet relevent content in order to increase the chances of a followback.

The API is as follows:

```ruby
require 'ausca'

bot = Ausca::Twitter::Bot.new({
  :consumer_key => TWITTER_API_KEY,
  :consumer_secret => TWITTER_API_SECRET,
  :access_token => TWITTER_ACCESS_TOKEN,
  :access_token_secret => TWITTER_ACCESS_SECRET,
  :config_filename => "config.json",
  :search => "#awesome -rt",
  :want_num_retweets => 1,
  :want_num_favorites => 3
})

# Run the bot once
bot.run
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Issues

Use the Github issue tracker if you find any bugs or have any feature requests: https://github.com/sourcey/ausca/issues