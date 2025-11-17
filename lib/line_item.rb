# frozen_string_literal: true

require 'bigdecimal'

# Represents a line item on a receipt with quantity, name, price and tax properties.
#
# A LineItem calculates its category and import status based on its name, which is used
# to determine tax exemptions and applicable import duties.
#
# @attr_reader [Integer] quantity the number of items
# @attr_reader [String] name the product name
# @attr_reader [BigDecimal] unit_price the price per unit
# @attr_reader [Symbol] category the product category (:book, :food, :medical or :other)
# @attr_reader [Boolean] imported whether the product is imported
class LineItem
  attr_reader :quantity, :name, :unit_price, :category, :imported

  # Mapping of product categories to identifying keywords
  CATEGORY_KEYWORDS = {
    book: %w[book books],
    food: %w[chocolate chocolates bar cake cakes candy candies],
    medical: %w[pill pills medicine headache]
  }.freeze

  # Creates a new line item with the given quantity, name and price.
  #
  # The category and import status are automatically determined based on the name.
  #
  # @param quantity [Integer] the number of items (must be positive)
  # @param name [String] the product name (case-insensitive for categorization)
  # @param unit_price [String, Numeric] the price per unit
  def initialize(quantity, name, unit_price)
    raise ArgumentError, 'quantity must be positive' unless quantity.positive?
    raise ArgumentError, 'name cannot be empty' if name.strip.empty?

    @quantity = quantity
    @name = name
    @unit_price = BigDecimal(unit_price)

    raise ArgumentError, 'unit_price must be positive' unless @unit_price.positive?

    @category = determine_category
    @imported = @name.include?('imported')
  end

  # Returns total base price before tax.
  #
  # @return [BigDecimal] quantity * unit price
  def base_total_price
    @unit_price * @quantity
  end

  # Returns whether the item is exempt from sales tax.
  #
  # @return [boolean] true if the item is a book, food or medical product
  def tax_exempt?
    %i[book food medical].include?(@category)
  end

  # Returns whether the item is imported.
  #
  # @return [boolean] true if the item is imported
  def imported?
    @imported
  end

  private

  # Determines the category of a product based on keywords in its name.
  #
  # @return [Symbol] the category (:book, :food, :medical, or :other)
  # @api private
  def determine_category
    clean_name = @name.gsub(/^imported\s+/, '').downcase

    CATEGORY_KEYWORDS.each do |category, keywords|
      return category if keywords.any? { |kw| clean_name.include?(kw) }
    end

    :other
  end
end
