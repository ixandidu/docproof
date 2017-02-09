module Docproof
  class PaymentProcessor
    class MissingDependency < Error; end

    MINIMUM_PRICE_IN_BTC = 0.005

    attr_reader :bitcoin_address,
                :price_in_btc

    def initialize(options={})
      require 'coinbase/wallet'

      @bitcoin_address = options['pay_address'] || options['payment_address']

      # `price` given by the API is in satoshis (100_000_000 satoshis = 1 BTC)
      # and it is only available after successfully `register!` a document.
      @price_in_btc = MINIMUM_PRICE_IN_BTC
      @price_in_btc = options['price'] / 100_000_000.0 if options['price']

    rescue LoadError => _
      raise MissingDependency,
            "Coinbase is required, You can install it with: `gem install coinbase`"
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
        Coinbase::Wallet::Client.new(
          api_key:    ENV.fetch('COINBASE_API_KEY'),
          api_secret: ENV.fetch('COINBASE_API_SECRET')
        ).primary_account
      end
  end
end
