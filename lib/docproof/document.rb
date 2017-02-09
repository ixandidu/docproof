module Docproof
  class Error < StandardError; end

  class Document
    class Existed < Error; end
    class Invalid < Error; end
    class NotFound < Error; end
    class AlreadyNotarized < Error; end

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

      if response['reason'] == 'existing'
        raise Existed, "\"#{sha256_hash}\" already registered"
      end

      if response['reason'] && response['reason'][/Invalid/]
        raise Invalid, "\"#{sha256_hash}\" is invalid"
      end

      response
    end

    def lookup!
      post(STATUS_ENDPOINT)

      if response['reason'] == 'nonexistent'
        raise NotFound, "\"#{sha256_hash}\" does not existed."
      end

      response
    end

    def notarize!
      if response['tx']
        raise AlreadyNotarized, "\"#{sha256_hash}\" is already notarized."
      end

      PaymentProcessor.new(response).perform!
    end

    private

      def post(uri)
        @response = JSON.parse(
          Net::HTTP.post_form(uri, d: sha256_hash).body
        ).delete_if { |_, value| value == '' }
      end
  end
end
