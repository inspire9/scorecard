# Scorecard

A Rails engine for tracking points, badges and levels for gamification.

For anyone who comes across this, please note this is not yet feature complete, and the API will very likely change.

## Installation

Add this line to your application's Gemfile:

    gem 'scorecard'

Don't forget to bundle:

    $ bundle

Then, add the migrations to your app and update your database accordingly:

    $ rake scorecard:install:migrations db:migrate

## Rules

In an initializer, define the events that points are tied to - with a unique context and the number of points:

```ruby
Scorecard::PointRule.new :new_post, 50
```

You can also provide a block with logic for whether to award the points:

```ruby
Scorecard::PointRule.new :new_post, 50 do |payload|
  payload[:user].posts.count <= 1
end
```

The payload object contains the context plus every option you send through to `score` call (see below).

## Scoring

And then, when you want to fire those events, use code much like the following:

```ruby
Scorecard::Points.score :new_post, gameable: post
```

This presumes that the user the points are for is a method on the gameable object. If that's not the case, you can pass in a custom user:

```ruby
Scorecard::Points.score :new_post, gameable: post, user: user
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Licence

Copyright (c) 2013, Scorecard is developed and maintained by [Inspire9](http://inspire9.com), and is released under the open MIT Licence.
