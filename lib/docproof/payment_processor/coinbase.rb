module Docproof
  class PaymentProcessor
    class Coinbase
      class Configuration
        attr_accessor :api_key,
                      :api_secret

        def initialize
          @api_key    = ENV['COINBASE_API_KEY']
          @api_secret = ENV['COINBASE_API_SECRET']
        end
      end

      attr_reader :recipient,
                  :amount

      def self.configuration
        @configuration ||= Configuration.new
      end

      def self.configuration=(config)
        @configuration = config
      end


      def self.configure
        yield configuration
      end

      def initialize(recipient:, amount:)
        if !Coinbase.configuration.api_key || !Coinbase.configuration.api_secret
          raise MissingCredentials, 'Coinbase API key and secret in not set'
        end

        @recipient = recipient
        @amount    = amount
      end

      def perform!
        coinbase_wallet_primary_account.send(
          to:       recipient,
          amount:   amount,
          currency: 'BTC'
        )
      end

      private

        def coinbase_wallet_primary_account
          require 'coinbase/wallet'

          @coinbase_wallet_primary_account ||= ::Coinbase::Wallet::Client.new(
            api_key:    Coinbase.configuration.api_key,
            api_secret: Coinbase.configuration.api_secret
          ).primary_account
        rescue LoadError
          raise MissingDependency,
            'Coinbase is required, You can install it with: `gem install coinbase`'
        end
    end
  end
end
