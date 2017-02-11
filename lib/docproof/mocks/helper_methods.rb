module Docproof
  module Mocks
    module HelperMethods
      def fixture_file(file_name)
        File.open(File.expand_path("fixtures/#{file_name}", __dir__))
      end
    end
  end
end

