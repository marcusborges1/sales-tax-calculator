# frozen_string_literal: true

require 'bigdecimal'

class LineItem
  attr_reader :quantity, :name, :unit_price, :category, :imported

  # Mapping of product categories to identifying keywords
  CATEGORY_KEYWORDS = {
    book: %w[book books],
    food: %w[chocolate chocolates bar cake cakes candy candies],
    medical: %w[pill pills medicine headache]
  }.freeze

  def initialize(quantity, name, unit_price)
    @quantity = quantity
    @name = name
    @unit_price = BigDecimal(unit_price)
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
  def determine_category
    clean_name = @name.gsub(/^imported\s+/, '').downcase

    CATEGORY_KEYWORDS.each do |category, keywords|
      return category if keywords.any? { |kw| clean_name.include?(kw) }
    end

    :other
  end
end
