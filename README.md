# gree-community

Access to GREE community.

## Installation

Add this line to your application's Gemfile:

    gem 'gree-community'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gree-community

## Usage

    require 'gree/community'

    fetcher = GREE::Community::Fetcher.new('your_email', 'password')

    community = GREE::Community.new('community id') # http://gree.jp/community/community_id

    community.fetch(fetcher)

    community.recent_threads.each do|thread|
      thread.fetch(fetcher)

      thread.recent_comments.each do|comment|
        puts "#{thread.title} #{comment.user_name} #{comment.body_text}"
      end
    end

See source for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Changes

### 0.0.2

Add missing dependency.

### 0.0.1

Initial release.
