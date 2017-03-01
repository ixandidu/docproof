module Docproof
  class PaymentProcessor
    class Coinbase
      class Configuration
        attr_accessor :api_key,
                      :api_secret,
                      :account_id

        def initialize(config={})
          @api_key    = config.fetch('api_key')    { ENV['COINBASE_API_KEY'] }
          @api_secret = config.fetch('api_secret') { ENV['COINBASE_API_SECRET'] }
          @account_id = config.fetch('account_id') { ENV['COINBASE_ACCOUNT_ID'] }
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

      def self.configure(config={})
        self.configuration = Configuration.new(config)
        yield configuration if block_given?
      end

      def initialize(options={})
        if !Coinbase.configuration.api_key || !Coinbase.configuration.api_secret
          raise MissingCredentials, 'Coinbase API key and secret in not set'
        end

        @recipient = options[:recipient]
        @amount    = options[:amount]
      end

      def perform!
        coinbase_account.send(
          to:       recipient,
          amount:   amount,
          currency: 'BTC'
        )
      end

      private

        def coinbase_client
          require 'coinbase/wallet'

          @coinbase_client ||= ::Coinbase::Wallet::Client.new(
            api_key:    Coinbase.configuration.api_key,
            api_secret: Coinbase.configuration.api_secret
          )
        rescue LoadError
          raise MissingDependency,
            'Coinbase is required, You can install it with: `gem install coinbase`'
        end

        def coinbase_account
          if account_id = Coinbase.configuration.account_id
            @coinbase_account = coinbase_client.account(account_id)
          else
            @coinbase_account = coinbase_client.primary_account
          end
        end
    end
  end
end
