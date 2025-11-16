require 'bigdecimal'

class LineItem
  attr_reader :quantity, :name, :unit_price, :imported

  def initialize(quantity, name, unit_price, imported)
    @quantity = quantity
    @name = name
    @unit_price = BigDecimal(unit_price)
    @imported = imported
  end
end