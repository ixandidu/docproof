module Docproof
  class Document
    require 'net/http'
    require 'json'

    REGISTER_ENDPOINT = URI('https://proofofexistence.com/api/v1/register')
    STATUS_ENDPOINT   = URI('https://proofofexistence.com/api/v1/status')

    attr_reader :sha256_hash,
                :response

    def initialize(sha256_hash)
      @sha256_hash = sha256_hash
    end

    def register!
      post(REGISTER_ENDPOINT)
    end

    def lookup!
      post(STATUS_ENDPOINT)
    end

    private

      def post(uri)
        JSON.parse(Net::HTTP.post_form(uri, d: sha256_hash).body).tap do |resp|
          @response = resp.delete_if { |key, value| value == '' }

          # Currently `resp['success']` can be either `true`, `false`, or
          # `"true"` (string).
          raise_error(resp['reason']) unless resp['success']
        end
      end

      def raise_error(api_response)
        raise RuntimeError, "The API response \"#{api_response}\""
      end
  end
end
