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
end