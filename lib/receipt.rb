# frozen_string_literal: true

require 'bigdecimal'
require_relative 'sales_tax_report'

# Calculates sales tax receipts for line items.
#
# Receipt calculates sales taxes based on two types of taxes:
# - Basic sales tax
# - Import duty
#
# @see LineItem
# @see https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36 Challenge specification
class Receipt
  # Basic sales tax rate (10%).
  BASIC_SALES_TAX = BigDecimal('0.10')
  # Import duty rate (5%).
  IMPORT_DUTY = BigDecimal('0.05')

  # Creates a new receipt for the given line items.
  #
  # @param line_items [Array<LineItem>] the items to include in the receipt
  def initialize(line_items)
    @line_items = line_items.freeze
  end

  # Calculates sales tax and totals for all line items.
  #
  # Processes each line item to calculate applicable taxes, then constructs and
  # returns a SalesTaxReport containing the items with taxes applied, total sales
  # taxes, and grand total.
  #
  # @return [SalesTaxReport] a report object containing items, sales taxes, and total
  def evaluate
    items = []
    sales_taxes = BigDecimal('0')
    total = BigDecimal('0')

    @line_items.each do |item|
      tax = calculate_tax(item)
      price_with_tax = item.base_total_price + tax

      sales_taxes += tax
      total += price_with_tax

      items << { quantity: item.quantity, name: item.name, price_with_tax: price_with_tax }
    end
    SalesTaxReport.new(items, sales_taxes, total)
  end

  private

  # Calculates the total tax for a line item.
  #
  # @param item [LineItem] the line item to calculate tax for
  # @return [BigDecimal] the total tax amount (rounded, multiplied by quantity)
  #
  # @api private
  def calculate_tax(item)
    tax_per_unit = BigDecimal('0')
    tax_per_unit += item.unit_price * BASIC_SALES_TAX unless item.tax_exempt?
    tax_per_unit += item.unit_price * IMPORT_DUTY if item.imported?

    round_up(tax_per_unit) * item.quantity
  end

  # Rounds a tax amount up to the nearest 0.05.
  #
  # This rounding is required by the challenge specification to ensure
  # tax amounts end in 0 or 5 cents (e.g., 1.47 becomes 1.50, 2.80 stays 2.80).
  #
  # @param amount [BigDecimal] the tax amount to round
  # @return [BigDecimal] the amount rounded up to nearest 0.05
  #
  # @see https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36 Challenge specification
  # @api private
  def round_up(amount)
    nearest_amount = BigDecimal('0.05')
    (amount / nearest_amount).ceil * nearest_amount
  end
end
