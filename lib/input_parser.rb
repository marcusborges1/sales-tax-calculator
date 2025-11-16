# frozen_string_literal: true

require_relative 'line_item'

# Parses input files containing line items for sales tax calculation.
#
# InputParser provides utilities to parse text files or individual lines into
# LineItem objects. The expected input format is:
#   quantity description at price
#
# Where:
# - quantity is a positive integer
# - description is the product name (may contains spaces and "imported")
# - price is a decimal number
#
# @example Parse a file with multiple items
#   items = InputParser.parse_file('fixtures/basic_items.txt')
#   items.each { |item| puts item.name }
#
# @example Parse a single line
#   item = InputParser.parse_line("1 book at 12.49")
#   item.name #=> "book"
#
# @see LineItem
class InputParser
  # Parses an entire file and returns an array of LineItem objects.
  #
  # Each line in the file is parsed independently. Empty lines are processed
  # as empty strings, which may raise ArgumentError. Ensure input files
  # contain only valid line item entries.
  #
  # @param filename [String] path to the input file
  # @return [Array<LineItem>] parsed line items
  #
  # @raise [Errno::ENOENT] if file doesn't exist
  # @raise [ArgumentError] if any line doesn't match the expected format
  #
  # @example Parse a file succcessfully
  #   items = InputParser.parse_file('fixtures/basic_items.txt')
  #   items.length #=> 3
  #
  # @example Handle a missing file
  #   begin
  #     InputParser.parse_file('nonexistent.txt')
  #   rescue Errno::ENOENT => e
  #     puts format("File not found: %<message>s", message: e.message)
  #   end
  def self.parse_file(filename)
    File.readlines(filename).map do |line|
      parse_line(line.strip)
    end
  end

  # Parses a single line of input.
  #
  # The line must follow the format "quantity name at price" where:
  # - quantity is one or more digits
  # - name is any text (may contain spaces)
  # - price is digits with optional decimal point
  #
  # @param line [String] input line in format "quantity name at price"
  # @return [LineItem] the parsed line item
  #
  # @raise [ArgumentError] if line does not match expected format
  #
  # @example Parse an imported item
  #   item = InputParser.parse_line("1 imported box of chocolates at 10.00")
  #   item.name #=> "imported box of chocolates"
  #   item.imported? #=> true
  #
  # @example Handle invalid format
  #   begin
  #     InputParser.parse_line("invalid line")
  #   rescue ArgumentError => e
  #     puts e.message #=> "expected format 'quantity name at price', got line 'invalid line' instead"
  #   end
  def self.parse_line(line)
    match = line.match(/^(\d+)\s+(.+)\s+at\s+([\d.]+)$/)

    raise ArgumentError, "expected format 'quantity name at price', got line '#{line}' instead" if match.nil?

    quantity = match[1].to_i
    name = match[2]
    price = match[3]

    LineItem.new(quantity, name, price)
  end
end
