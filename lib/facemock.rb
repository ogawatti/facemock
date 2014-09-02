require "facemock/version"
require "facemock/config"
require "facemock/fb_graph"
require "facemock/database"
require "facemock/errors"
require "facemock/auth_hash"

module Facemock 
  extend self

  def on
    Facemock::FbGraph.on
  end

  def off
    Facemock::FbGraph.off
  end

  def on?
    FbGraph == Facemock::FbGraph
  end

  def auth_hash(access_token=nil)
    if access_token.kind_of?(String) && access_token.size > 0
      user = Facemock::Database::User.find_by_access_token(access_token)
      if user
        Facemock::AuthHash.new({
          provider:    "facebook",
          uid:         user.id,
          info:        { name:     user.name },
          credentials: { token:    access_token, expires_at: Time.now + 60.days },
          extra:       { raw_info: { id: user.id, name: user.name } }
        })
      else
        Facemock::AuthHash.new
      end
    else
      Facemock::AuthHash.new
    end
  end
end
