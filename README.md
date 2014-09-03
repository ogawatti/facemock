[![Gem Version](https://badge.fury.io/rb/facemock.svg)](http://badge.fury.io/rb/facemock)
[![Build Status](https://travis-ci.org/ogawatti/facemock.svg?branch=master)](https://travis-ci.org/ogawatti/facemock)
[![Coverage Status](https://coveralls.io/repos/ogawatti/facemock/badge.png?branch=master)](https://coveralls.io/r/ogawatti/facemock?branch=master)
[<img src="https://gemnasium.com/ogawatti/facemock.png" />](https://gemnasium.com/ogawatti/facemock)
[![Code Climate](https://codeclimate.com/github/ogawatti/facemock.png)](https://codeclimate.com/github/ogawatti/facemock)

# Facemock

Facemock is facebook mock application for FbGraph.

## Installation

Add this line to your application's Gemfile:

    gem 'facemock'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install facemock

## Usage

### Mock on/off

for all gem

    require 'facemock'

    FbGraph       #=> FbGraph
    Facemock.on
    FbGraph       #=> Facemock::FbGraph
    Facemock.off
    FbGraph       #=> FbGraph

for specified gem

    require 'facemock'

    FbGraph       #=> FbGraph
    Facemock::FbGraph.on
    FbGraph       #=> Facemock::FbGraph
    Facemock::FbGraph.off
    FbGraph       #=> FbGraph

### Test User

    require 'facemock'

    Facemock.on
    facebook_app_id     = "100000000000000"
    facebook_app_secret = "facemock_app_secret"
    app = FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)


    ## Create Test User
    user = app.test_user!
    user = app.test_user!( { name: "test user", permissions: "email, read_stream" } )
    user.name         #=> "test user"
    user.permissions  #=> [:email, :read_stream]


    ## Get Created Test User
    app.test_users  #=> [#<Facemock::FbGraph::Application::User id: ...>, ...]
    app.test_users.size  #=> 2
    test_users.first     #=> User that was created at the last
    test_users.last      #=> User that was created at the first

    test_users = app.test_users({ limit: 1, after: 1 })
    test_users.size = 1
    test_users.first.id  #=> [#<Facemock::FbGraph::Application::User id: ...>, ...]


    # Delete Test User
    app.test_users.size           #=> 2
    app.test_users.first.destroy
    app.test_users.size           #=> 1
    app.test_users.first.destroy
    app.test_users                #=> []

### User

    require 'facemock'

    Facemock.on
    facebook_app_id     = "100000000000000"
    facebook_app_secret = "facemock_app_secret"
    app  = FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
    user = app.test_user!({name: "face mock", permissions: "email, read_stream"})
    access_token = user.access_token

    # Get User by Access Token
    user = FbGraph::User.me(access_token)
    user.name         #=> "face mock"
    user.permissions  #=> [:email, :read_stream]

    # Delete permission
    user.revoke!
    user.permissions  #=> []

    # Delete User
    user.destroy
    FbGraph::User.me(access_token)  #=> nil

### Register Test User by yaml file

    require 'facemock'

    Facemock::FbGraph.on
    Facemock::Config.load_users("./test_users.yml")

yaml file see below.

    ---
    - :app_id: '000000000000001'
      :app_secret: test_secret_one
      :users:
      - :identifier: 100000000000001
        :name: test user one
        :email: test_user_one@example.com
        :password: testpass
      - :identifier: '100000000000002'
        :name: test user two
        :email: test_user_two@example.com
        :password: testpass
    - :app_id: '000000000000002'
      :app_secret: test_secret_two
      :users:
      - :identifier: 100000000000003
        :name: test user three
        :email: test_user_three@example.com
        :password: testpass

### AuthHash

    require 'facemock'

    app  = Facemock::Database::Application.create!
    user = Facemock::Database::User.craete!(application_id: app.id)
    auth_hash = Facemock.auth_hash(user.access_token)

    # auth_hash == { "provider"    => "facebook", 
    #                "uid"         => 100007315962084,
    #                "info"        => { "name"       => "c6fyxii0u2" },
    #                "credentials" => { "token"      => "d4a88140f1...",
    #                                   "expires_at" => 2014-11-02 09:09:51 +0900 },
    #                "extra"       => { "raw_info"   => { "id"   => 100007315962084, 
    #                                                   "name" => "c6fyxii0u2" } } }

### Exception

    require 'facemock'

    Facemock.on
    begin
      raise FbGraph::InvalidToken.new "test exception"
    rescue => e
      puts "#{e.class} : #{e.message}"  #=> Facemock::FbGraph::InvalidToken : test exception
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
