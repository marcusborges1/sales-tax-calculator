# frozen_string_literal: true

# Calculates sales tax receipts for line items.
#
# Receipt calculates sales taxes based on two types of taxes:
# - Basic sales tax
# - Import duty
#
# @example Generate a receipt for basic items
#   items = [
#     LineItem.new(1, "book", "12.49"),
#     LineItem.new(1, "music CD", "14.99")
#   ]
#   receipt = Receipt.new(items)
#   receipt.evaluate
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
  #
  # @example
  #   items = [
  #     LineItem.new(2, "book", "12.49"),
  #     LineItem.new(1, "music CD", "14.99")
  #   ]
  #   receipt = Receipt.new(items)
  def initialize(line_items)
    @line_items = line_items
  end

  # Prints a formatted sales tax receipt to stdout.
  #
  # The receipt includes:
  # - Each item with quantity, name, and total price including tax
  # - Total sales taxes collected
  # - Grand total of all items with tax
  #
  # @return [void]
  #
  # @example Output format
  #   receipt.evaluate
  #   # 1 book: 12.49
  #   # 1 music CD: 16.49
  #   # 1 imported box of chocolates: 10.50
  #   # Sales Taxes: 2.00
  #   # Total: 39.48
  def evaluate
    sales_taxes = BigDecimal('0')
    total = BigDecimal('0')

    @line_items.each do |item|
      tax = calculate_tax(item)
      price_with_tax = item.base_total_price + tax

      sales_taxes += tax
      total += price_with_tax

      puts format('%<quantity>d %<name>s: %<price>.2f', quantity: item.quantity, name: item.name, price: price_with_tax)
    end

    puts format('Sales Taxes: %<taxes>.2f', taxes: sales_taxes)
    puts format('Total: %<total>.2f', total: total)
  end

  private

  # Calculates the total tax for a line item.
  #
  # @param item [LineItem] the line item to calculate tax for
  # @return [BigDecimal] the total tax amount (rounded, multiplied by quantity)
  #
  # @example Tax-exempt, non-imported item (no tax)
  #   item = LineItem.new(1, "book", "12.49")
  #   calculate_tax(item) #=> BigDecimal("0.00")
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
  # @example Round up various amounts
  #   round_up(BigDecimal("1.499")) #=> BigDecimal("1.50")
  #   round_up(BigDecimal("1.50"))  #=> BigDecimal("1.50")
  #   round_up(BigDecimal("1.51"))  #=> BigDecimal("1.55")
  #   round_up(BigDecimal("0.00"))  #=> BigDecimal("0.00")
  #
  # @see https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36 Challenge specification
  # @api private
  def round_up(amount)
    nearest_amount = BigDecimal('0.05')
    (amount / nearest_amount).ceil * nearest_amount
  end
end
