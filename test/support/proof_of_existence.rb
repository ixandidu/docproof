module ProofOfExistence
  require 'sinatra/base'

  class FakeAPI < Sinatra::Base
    post '/api/v1/:end_point' do
      content_type :json

      # The Proof of Existence API will only response with "400 Bad Request"
      # when we `register` an invalid sha256 hash.
      status params['d'][/invalid/] ? 400 : 200

      File.open(
        File.expand_path(
          "fixtures/#{params['end_point']}-#{params['d']}.json",
          __dir__
        )
      )
    end
  end
end
