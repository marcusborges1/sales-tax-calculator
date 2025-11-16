class Receipt
  # These values were defined on challenge specification, that can be found
  # on: https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36
  BASIC_SALES_TAX = BigDecimal("0.10")
  IMPORT_DUTY = BigDecimal("0.05")

  def initialize(line_items)
    @line_items = line_items
  end

  # Prints a sales tax receipt to stdout.
  #
  # The receipt includes:
  # - Price with tax for each item
  # - Total sales taxes
  # - Total price
  #
  # @return [void]
  def evaluate
    sales_taxes = BigDecimal("0")
    total = BigDecimal("0")

    @line_items.each do |item|
      tax = calculate_tax(item)
      price_with_tax = item.base_total_price + tax

      sales_taxes += tax
      total += price_with_tax

      puts "#{item.quantity} #{item.name}: #{'%.2f' % price_with_tax}"
    end

    puts "Sales Taxes: #{'%.2f' % sales_taxes}"
    puts "Total: #{'%.2f' % total}"
  end

  private

  # Calculates the total tax for a line item.
  #
  # @param item [LineItem] the line item to calculate
  # @return [BigDecimal] the rounded tax amount
  def calculate_tax(item)
    tax_per_unit = BigDecimal("0")
    tax_per_unit += item.unit_price * BASIC_SALES_TAX unless item.tax_exempt?
    tax_per_unit += item.unit_price * IMPORT_DUTY if item.imported?

    round_up(tax_per_unit) * item.quantity
  end

  # Rounds tax amount up to the nearest 0.05.
  #
  # The 0.05 value was defined by the challenge itself and can be found
  # on: https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36.
  #
  # @param amount [BigDecimal] the tax amount to round
  # @return [BigDecimal] the rounded amount
  def round_up(amount)
    nearest_amount = BigDecimal("0.05")
    (amount / nearest_amount).ceil * nearest_amount
  end
end