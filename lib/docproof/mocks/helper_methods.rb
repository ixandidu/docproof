module Docproof
  module Mocks
    module HelperMethods
      def json_file(file_name)
        File.open(File.expand_path("fixtures/#{file_name}.json", __dir__))
      end
    end
  end
end

