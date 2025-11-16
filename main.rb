# frozen_string_literal: true

# This ensures this codebase will only use gems specificed on Gemfile
# on specified versions.
require 'bundler/setup'

require_relative 'lib/input_parser'
require_relative 'lib/receipt'

# Accepts filename as argument of default to 'fixtures/basic_items.txt'
# Example: ruby main.rb fixtures/imported_items.txt
filename = ARGV[0] || 'fixtures/basic_items.txt'

begin
  items = InputParser.parse_file(filename)
  receipt = Receipt.new(items)
  report = receipt.evaluate
  report.print
rescue StandardError => e
  puts format('An error occured: <error>%s', error: e.message)
end
