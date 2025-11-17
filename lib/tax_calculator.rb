# frozen_string_literal: true

# Calculates sales tax for line items based on tax exemptions and import status.
#
# This calculator applies two types of taxes:
# - Basic sales tax (10%) on non-exempt items
# - Import duty (5%) on imported items
#
# Tax amounts are rounded up to the nearest 0.05 per the challenge specification.
#
# @see LineItem
# @see https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36 Challenge specification
class TaxCalculator
  # Basic sales tax rate (10%).
  BASIC_SALES_TAX = BigDecimal('0.10')
  # Import duty rate (5%).
  IMPORT_DUTY = BigDecimal('0.05')

  # Calculates the total tax for a line item.
  #
  # @param item [LineItem] the line item to calculate tax for
  # @return [BigDecimal] the total tax amount (rounded, multiplied by quantity)
  def calculate(line_item)
    tax_per_unit = BigDecimal('0')
    tax_per_unit += line_item.unit_price * BASIC_SALES_TAX unless line_item.tax_exempt?
    tax_per_unit += line_item.unit_price * IMPORT_DUTY if line_item.imported?

    round_up(tax_per_unit) * line_item.quantity
  end

  private

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
