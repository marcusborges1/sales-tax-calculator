# frozen_string_literal: true

# This ensures this codebase will only use gems specificed on Gemfile
# on specified versions.
require 'bundler/setup'

require_relative 'lib/input_parser'

# Accepts filename as argument of default to 'fixtures/basic_items.txt'
# Example: ruby main.rb fixtures/imported_items.txt
filename = ARGV[0] || 'fixtures/basic_items.txt'

# Temporarily showing only parsing
items = InputParser.parse_file(filename)
items.each do |item|
  puts format('%<quantity>d %<name>s - %<price>.2f', quantity: item.quantity, name: item.name, price: item.unit_price)
end
