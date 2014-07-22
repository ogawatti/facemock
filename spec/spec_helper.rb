$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# gemのより先に読み込む必要がある
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'facemock'
