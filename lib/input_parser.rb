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
  def self.parse_file(filename)
    File.readlines(filename).map.with_index do |line, index|
      stripped_line = line.strip

      next if stripped_line.empty?

      begin
        parse_line(line.strip)
      rescue ArgumentError => e
        raise ArgumentError, "Line #{index + 1}: #{e.message}"
      end
    end.compact
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
  def self.parse_line(line)
    match = line.match(/^(\d+)\s+(.+)\s+at\s+([\d.]+)$/)

    raise ArgumentError, "expected format 'quantity name at price', got line '#{line}' instead" if match.nil?

    quantity = match[1].to_i
    name = match[2]
    price = match[3]

    LineItem.new(quantity, name, price)
  end
end
