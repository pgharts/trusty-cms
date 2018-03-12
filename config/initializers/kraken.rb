require 'rubygems'
require 'kraken-io'

$kraken = Kraken::API.new(
    :api_key => ENV['KRAKEN_KEY'],
    :api_secret => ENV['KRAKEN_SECRET']
)
