# frozen_string_literal: true

require 'bigdecimal'

class LineItem
  attr_reader :quantity, :name, :unit_price, :category, :imported

  def initialize(quantity, name, unit_price, category, imported)
    @quantity = quantity
    @name = name
    @unit_price = BigDecimal(unit_price)
    @category = category
    @imported = imported
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
end
