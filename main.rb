# frozen_string_literal: true

# This ensures this codebase will only use gems specificed on Gemfile
# on specified versions.
require 'bundler/setup'

require_relative 'lib/input_parser'
require_relative 'lib/receipt'

# Accepts filename as argument of default to 'fixtures/basic_items.txt'
# Example: ruby main.rb fixtures/imported_items.txt
filename = ARGV[0] || 'fixtures/basic_items.txt'

unless File.exist?(filename)
  puts "Error: File '#{filename}' does not exist."
  exit 1
end

if File.empty?(filename)
  puts "Error: File '#{filename}' is empty."
  exit 1
end

begin
  items = InputParser.parse_file(filename)
  receipt = Receipt.new(items)
  report = receipt.evaluate_report
  report.print
rescue Errno::ENOENT => e
  puts "Error: Could not find file - #{e.message}"
  exit 1
rescue ArgumentError => e
  puts "Error: Invalid input format - #{e.message}"
  exit 1
rescue StandardError => e
  puts "Error: An unexpected error occurred - #{e.message}"
  exit 1
end
