require 'simplecov'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'docproof'
require 'docproof/mocks'

require 'minitest/spec'
require 'minitest/autorun'
require 'support/webmock'
