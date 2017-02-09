module ProofOfExistence
  require 'sinatra/base'

  class FakeAPI < Sinatra::Base
    include HelperMethods

    post '/api/v1/:end_point' do
      content_type :json

      # The Proof of Existence API will only response with "400 Bad Request"
      # when we `register` an invalid sha256 hash.
      status params['d'][/invalid/] ? 400 : 200

      fixture_file "#{params['end_point']}-#{params['d']}.json"
    end
  end
end
