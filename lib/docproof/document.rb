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
      raise Existed if response['reason'] == 'existing'
      raise Invalid if response['reason'] && response['reason'][/Invalid/]
      response
    end

    def lookup!
      post(STATUS_ENDPOINT)
      raise NotFound if response['reason'] == 'nonexistent'
      response
    end

    def notarize!
      raise AlreadyNotarized if response['tx']
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
