require 'facemock'

module Facemock
  module Authentication
    extend self

    PATH = "/facemock/authentication"
    CALLBACK_PATH = "/users/auth/facebook/callback"

    def call(env)
      raw_body = URI.unescape(env['rack.input'].gets)
      body     = query_string_to_hash(raw_body)
      email    = body["email"]
      password = body["pass"]

      user = Facemock::User.find_by_email(email)
      location = if user && user.password == password
        code = Facemock::AuthorizationCode.create!(user_id: user.id)
        generate_location_header(env, callback_path, { code: code.string })
      else
        generate_location_header(env, Facemock::Login.path)
      end

      code   = 302
      body   = []
      header = { "Content-Type"           => "text/html;charset=utf-8",
                 "Location"               => location,
                 "Content-Length"         => "0",
                 "X-XSS-Protection"       => "1; mode=block",
                 "X-Content-Type-Options" => "nosniff",
                 "X-Frame-Options"        => "SAMEORIGIN" }
      [ code, header, body ]
    end

    def path
      PATH
    end

    def callback_path
      CALLBACK_PATH
    end

    private

    def generate_location_header(env, path, query={})
      scheme = env["rack.url_scheme"]
      host   = env["HTTP_HOST"]
      query_string = query.empty? ? "" : "?" + hash_to_query_string(query)
      url = scheme + "://" + host + path + query_string
    end

    def query_string_to_hash(query_string)
      query_string.split("&").inject({}) do |hash, str|
        key, value = str.split("=")
        hash[key] = value
        hash
      end
    end

    def hash_to_query_string(query)
      query_strings = query.inject([]) do |ary, (key,value)|
        ary << "#{key}=#{value}"
      end
      query_strings.join("&")
    end
  end
end
