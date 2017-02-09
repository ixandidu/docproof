module Docproof
  class PaymentProcessor
    class MissingDependency < Error; end
    class MissingCredentials < Error; end

    BTC_IN_SATOSHIS      = 100_000_000
    MINIMUM_PRICE_IN_BTC = 0.005

    attr_reader :bitcoin_address,
                :price_in_btc

    def initialize(options={})
      @bitcoin_address = options['pay_address'] || options['payment_address']

      # `price` given by the API is in satoshis (100_000_000 satoshis = 1 BTC)
      # and it is only available after successfully `register!` a document.
      @price_in_btc = MINIMUM_PRICE_IN_BTC
      @price_in_btc = options['price'].to_f / BTC_IN_SATOSHIS if options['price']
    end

    def perform!
      coinbase_wallet_primary_account.send(
        to:       bitcoin_address,
        amount:   price_in_btc,
        currency: 'BTC'
      )
    end

    private

      def coinbase_wallet_primary_account
        require 'coinbase/wallet'

        Coinbase::Wallet::Client.new(
          api_key:    ENV.fetch('COINBASE_API_KEY'),
          api_secret: ENV.fetch('COINBASE_API_SECRET')
        ).primary_account
      rescue LoadError
        raise MissingDependency,
              'Coinbase is required, You can install it with: `gem install coinbase`'
      rescue KeyError
        raise MissingCredentials,
              'Please set `COINBASE_API_KEY` and `COINBASE_API_SECRET` environment variables'
      end
  end
end
