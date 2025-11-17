# frozen_string_literal: true

# SalesTaxReport generates a formatted sales receipt report.
#
# This class is responsible for formatting and displaying a sales receipt
# that includes itemized products with their prices including tax,
# the total sales taxes applied, and the total amount.
#
# @attr_reader [Array<Hash>] items the list of items with quantity, name, and price_with_tax
# @attr_reader [Float] sales_taxes the total sales taxes applied to all items
# @attr_reader [Float] total the total including all items and taxes
class SalesTaxReport
  attr_reader :items, :sales_taxes, :total

  # Initializes a new SalesTaxReport instance.
  #
  # @param items [Array<Hash>] an array of hashes containing item details.
  #   Each hash should have :quantity, :name, and :price_with_tax keys.
  # @param sales_taxes [Float] the total amount of sales taxes applied
  # @param total [Float] the total amount including all items and taxes
  #
  # @return [SalesTaxReport] a new instance of SalesTaxReport
  def initialize(items, sales_taxes, total)
    @items = items
    @sales_taxes = sales_taxes
    @total = total
  end

  # Prints the formatted sales receipt to standard output.
  #
  # The receipt includes:
  # - Each item with its quantity, name, and price (with tax) formatted to 2 decimal places
  # - Total sales taxes formatted to 2 decimal places
  # - Grand total formatted to 2 decimal places
  #
  # @return [void]
  def print
    @items.each do |item|
      puts format('%<quantity>d %<name>s: %<price>.2f',
                  quantity: item[:quantity],
                  name: item[:name],
                  price: item[:price_with_tax])
    end
    puts format('Sales Taxes: %<taxes>.2f', taxes: @sales_taxes)
    puts format('Total: %<total>.2f', total: @total)
  end
end
