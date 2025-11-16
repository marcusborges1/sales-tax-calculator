# frozen_string_literal: true

require_relative 'line_item'

# Parses input files containing line items for sales tax calculation.
#
# The input format expects lines in the form:
#   quantity description at price
#
# @example Parse a file
#   items = InputParser.parse_file('input1.txt')
#
class InputParser
  # Parses an entire file and returns an array of LineItem objects.
  #
  # @param filename [String] path to the input file
  # @return [Array<LineItem>] parsed line items
  # @raise [Errno::ENOENT] if file doesn't exist
  def self.parse_file(filename)
    File.readlines(filename).map do |line|
      parse_line(line.strip)
    end
  end

  # Parses a single line of input.
  #
  # @param line [String] input line in format "quantity name at price"
  # @return [LineItem] the parsed line item
  # @raise [ArgumentError] if line does not match expected format
  # @example
  #   InputParser.parse_line("1 imported box fo chocolates at 10.00")
  def self.parse_line(line)
    match = line.match(/^(\d+)\s+(.+)\s+at\s+([\d.]+)$/)

    raise ArgumentError, "expected format 'quantity name at price', got line '#{line}' instead" if match.nil?

    quantity = match[1].to_i
    name = match[2]
    price = match[3]

    LineItem.new(quantity, name, price)
  end
end
