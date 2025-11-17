# frozen_string_literal: true

require 'bigdecimal'
require_relative 'sales_tax_report'
require_relative 'tax_calculator'

# Calculates sales tax receipts for line items.
#
# @see LineItem
# @see TaxCalculator
class Receipt
  # Creates a new receipt for the given line items.
  #
  # @param line_items [Array<LineItem>] the items to include in the receipt
  # @param tax_calculator [TaxCalculator] the tax calculator to use for calculating taxes (defaults to
  # a new TaxCalculator instance)
  def initialize(line_items, tax_calculator: TaxCalculator.new)
    @line_items = line_items.freeze
    @tax_calculator = tax_calculator
  end

  # Calculates sales tax and totals for all line items.
  #
  # Processes each line item to calculate applicable taxes, then constructs and
  # returns a SalesTaxReport containing the items with taxes applied, total sales
  # taxes, and grand total.
  #
  # @return [SalesTaxReport] a report object containing items, sales taxes, and total
  def evaluate_report
    items = []
    sales_taxes = BigDecimal('0')
    total = BigDecimal('0')

    @line_items.each do |item|
      tax = @tax_calculator.calculate(item)
      price_with_tax = item.base_total_price + tax

      sales_taxes += tax
      total += price_with_tax

      items << { quantity: item.quantity, name: item.name, price_with_tax: price_with_tax }
    end
    SalesTaxReport.new(items, sales_taxes, total)
  end
end
