# Docproof [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/ixandidu/docproof/master/LICENSE.md) [![Gem](https://img.shields.io/gem/v/docproof.svg?style=flat-square)](https://rubygems.org/gems/docproof) [![Code Climate](https://codeclimate.com/github/ixandidu/docproof/badges/gpa.svg)](https://codeclimate.com/github/ixandidu/docproof) [![Test Coverage](https://codeclimate.com/github/ixandidu/docproof/badges/coverage.svg)](https://codeclimate.com/github/ixandidu/docproof/coverage) [![Issue Count](https://codeclimate.com/github/ixandidu/docproof/badges/issue_count.svg)](https://codeclimate.com/github/ixandidu/docproof) [![Build Status](https://travis-ci.org/ixandidu/docproof.svg?branch=master)](https://travis-ci.org/ixandidu/docproof)

Client library for [Proof of Existence API](https://proofofexistence.com/developers).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'docproof'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docproof

## Configuration

If you want to use `Docproof::Document#notarize!` you'll need to set the following environment variables (Note that we are currently only support [Coinbase](https://github.com/coinbase/coinbase-ruby)):


    COINBASE_API_KEY=YOUR-COINBASE-API-KEY
    COINBASE_API_SECRET=YOUR-COINBASE-API-SECRET
    COINBASE_ACCOUNT_ID=YOUR-COINBASE-ACCOUNT-ID # this is optional, we'll use your primary_account if you don't specify this

and require the `coinbase/wallet`, e.g.:

```ruby
require 'coinbase/wallet`

docproof_document = Docproof::Document.new('y0urd0cum3nt5ha256h45h')
docproof_document.register! && docproof_document.notarize!
```

You can also configure the Coinbase API Key, Secret and Account ID like so:

```ruby
require 'coinbase/wallet`

#
# Docproof::PaymentProcessor::Coinbase.configure do |config|
#   config.api_key    = 'YOUR-COINBASE-API-KEY'
#   config.api_secret = 'YOUR-COINBASE-API-SECRET'
#   config.api_secret = 'YOUR-COINBASE-ACCOUNT-ID'
# end
#
# or pass a hash as configuration (the hash key must be string)

Docproof::PaymentProcessor::Coinbase.configure(
  'api_key'    => 'YOUR-COINBASE-API-KEY'
  'api_secret' => 'YOUR-COINBASE-API-SECRET'
  'api_secret' => 'YOUR-COINBASE-ACCOUNT-ID'
)

docproof_document = Docproof::Document.new('y0urd0cum3nt5ha256h45h')
docproof_document.register! && docproof_document.notarize!
```

## Usage

To register a new document's SHA256 digest:

```ruby
docproof_document.register!
```

To post the registered document SHA256 digest to the blockchain (make payment to the indicated bitcoin address using the Coinbase you've specify):

```ruby
docproof_document.notarize!
```

To lookup the status of the registered document's SHA256 digest:

```ruby
docproof_document.lookup!
```

## Response

The JSON response is stored in `Docproof::Document#response` and keys with the value of empty string are ignored.

### Errors

If the request is not successful, the gem will raise an error. All errors are subclasses of `Docproof::Error`.
