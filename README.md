# Docproof [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/ixandidu/docproof/master/LICENSE.md) [![Gem](https://img.shields.io/gem/v/docproof.svg?style=flat-square)](https://rubygems.org/gems/docproof) [![Code Climate](https://codeclimate.com/github/ixandidu/docproof/badges/gpa.svg)](https://codeclimate.com/github/ixandidu/docproof)

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

Currently the only supported Bitcoin Payment Gateway is [Coinbase](https://github.com/coinbase/coinbase-ruby), so if you want to use the `Docproof::Document#notarize!` you'll need to set the following environment variables:

    COINBASE_API_KEY=YOUR-COINBASE-API-KEY
    COINBASE_API_SECRET=YOUR-COINBASE-API-SECRET

and requires `coinbase/wallet`

```ruby
require 'coinbase/wallet`

docproof_document = Docproof::Document.new('y0urd0cum3nt5ha256h45h') 
```

## Usage

To register a new document's SHA256 digest:

```ruby
doc.register!
```

To post the document's SHA256 digest to the blockchain (making payment to indicated bitcoind address):

```ruby
doc.notarize!
```

To lookup the status of the document's SHA256 digest:

```ruby
doc.lookup!
```

## Response

The JSON response is stored in `Docproof::Document#response` and keys with the value of empty string are ignored.

### Errors

If the request is not successful, the gem will raise an error. All errors are subclasses of `Docproof::Document::Errors`.
