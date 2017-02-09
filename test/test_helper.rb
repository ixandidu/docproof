require 'simplecov'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'docproof'

require 'minitest/spec'
require 'minitest/autorun'
require 'support/webmock'
require 'support/helper_methods'

class Minitest::Spec
  include HelperMethods
end
