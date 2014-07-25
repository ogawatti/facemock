require 'fb_graph'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'facemock'

#facebook_app_id     = "404983972899486"
#facebook_app_secret = "81fc41663b2e8d09293220e0647bc75a"
facebook_app_id     = "100000000000000"
facebook_app_secret = "facemock_app_secret"

# Mockのon/off確認
puts "===== Mock on/off check ======"
p FbGraph              #=> FbGraph
Facemock.on
p FbGraph              #=> Mock::FbGraph
Facemock.off
p FbGraph              #=> FbGraph
puts
p FbGraph              #=> FbGraph
Facemock::FbGraph.on
p FbGraph              #=> Mock::FbGraph
Facemock::FbGraph.off
p FbGraph              #=> FbGraph

Facemock::FbGraph.on

# Database操作
puts "===== Database Operation ====="
puts "Now Processing ..."
database = Facemock::Config.database
database.disconnect!
database.connect
database.clear
database.disconnect!
database.drop
database = Facemock::Config::Database.new("test")
database.drop
puts "Completed!"

# ユーザ操作確認
puts "======= User Operation ======="
app   = FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)

user  = app.test_user!
user.fetch
user.destroy

user  = app.test_user!({ permissions: "email, read_stream"})
binding.pry
user.revoke!
user  = FbGraph::User.me(user.access_token)

users = app.test_users({ limit: 1, after: 1 })
users = users.next

access_token = app.test_users.first.access_token
user  = FbGraph::User.me(access_token)
puts "#{user.id} #{user.name}"

app   = FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret, database_name: "test")
users = app.test_users({ limit: 1, after: 1 })
Facemock::Config.database.drop

database = Facemock::Config::Database.new("test")
database.drop

# 例外確認
puts "====== Exception check ======="
begin
  raise FbGraph::Errors::InvalidToken.new "test exception"
rescue => e
  puts "#{e.class} : #{e.message}"
end
