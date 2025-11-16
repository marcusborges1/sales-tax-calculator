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
    # Mapping of product categories to identifying keywords
    CATEGORY_KEYWORDS = {
        book: %w[book books],
        food: %w[chocolate chocolates bar cake cakes candy candies],
        medical: %w[pill pills medicine headache]
    }

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
    # @example
    #   InputParser.parse_line("1 imported box fo chocolates at 10.00")
    def self.parse_line(line)
        match = line.match(/^(\d+)\s+(.+)\s+at\s+([\d.]+)$/)

        quantity = match[1].to_i
        name = match[2]
        price = match[3]

        category = determine_category(name)
        imported = name.include?("imported")

        LineItem.new(quantity, name, price, category, imported)
    end

    # Determines the category of a product based on keywords in its name.
    #
    # @param name [String] the product name
    # @return [Symbol] the category (:book, :food, :medical, or :other)
    # @example
    #   InputParser.determine_category("imported book")
    def self.determine_category(name)
      clean_name = name.gsub(/^imported\s+/, '').downcase

      CATEGORY_KEYWORDS.each do |category, keywords|
        return category if keywords.any? { |kw| clean_name.include?(kw) }
      end

      :other
    end
end