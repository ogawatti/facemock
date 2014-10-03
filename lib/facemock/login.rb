module Facemock
  module Login
    extend self

    PATH = "/facemock/sign_in"
    VIEW_DIRECTORY = File.expand_path("../../../view", __FILE__)
    VIEW_FILENAME  = "login.html"

    def call(env)
      code   = 200
      body   = [ view ]
      header = { "Content-Type"           => "text/html;charset=utf-8",
                 "Content-Length"         => content_length(body).to_s,
                 "X-XSS-Protection"       => "1; mode=block",
                 "X-Content-Type-Options" => "nosniff",
                 "X-Frame-Options"        => "SAMEORIGIN" }
      [code, header, body]
    end

    def path
      PATH
    end

    def view
      File.read(filepath)
    end

    private

    def content_length(body)
      body.inject(0) do |sum, content|
        sum + content.bytesize
      end
    end

    def filepath
      File.join(VIEW_DIRECTORY, VIEW_FILENAME)
    end
  end
end
