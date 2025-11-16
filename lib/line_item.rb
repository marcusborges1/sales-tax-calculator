require 'bigdecimal'

class LineItem
  attr_reader :quantity, :name, :unit_price

  def initialize(quantity, name, unit_price)
    @quantity = quantity
    @name = name
    @unit_price = BigDecimal(unit_price)
  end
end