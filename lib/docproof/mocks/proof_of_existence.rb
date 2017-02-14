module Docproof
  module Mocks
    module ProofOfExistence
      require 'sinatra/base'

      class FakeAPI < Sinatra::Base
        include Docproof::Mocks::HelperMethods

        post '/api/v1/:end_point' do
          content_type :json

          @@simulations ||= []
          if params['d'].start_with?('sequence') && @@simulations.empty?
            @@simulations = params['d'].split('_').reverse
            @@simulations.pop
          end
          params_digest = @@simulations.any? ? @@simulations.pop : params['d']
          file_name     = "#{params['end_point']}/#{params_digest}"

          # The Proof of Existence API will only response with "400 Bad Request"
          # when we `register` an invalid sha256 hash.
          status params_digest[/invalid/] ? 400 : 200

          json_file file_name
        end
      end
    end
  end
end
