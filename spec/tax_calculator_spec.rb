# frozen_string_literal: true

require 'spec_helper'
require 'bigdecimal'
require_relative '../lib/tax_calculator'
require_relative '../lib/line_item'

RSpec.describe TaxCalculator do
  let(:calculator) { described_class.new }

  describe '#calculate' do
    context 'basic sales tax (10%) on non-exempt items' do
      it 'returns tax as BigDecimal' do
        item = LineItem.new(1, 'music CD', '14.99')
        tax = calculator.calculate(item)

        expect(tax).to be_a(BigDecimal)
      end

      it 'calculates tax for a bottle of perfume' do
        item = LineItem.new(1, 'bottle of perfume', '18.99')
        tax = calculator.calculate(item)

        # 18.99 * 0.10 = 1.899, rounded up to 1.90
        expect(tax).to eq(BigDecimal('1.90'))
      end
    end

    context 'import duty (5%) on imported items' do
      it 'calculates import duty for imported chocolates (tax-exempt category)' do
        item = LineItem.new(1, 'imported box of chocolates', '10.00')
        tax = calculator.calculate(item)

        # 10.00 * 0.05 = 0.50
        expect(tax).to eq(BigDecimal('0.50'))
      end
    end

    context 'tax exemptions' do
      it 'exempts books from basic sales tax' do
        item = LineItem.new(1, 'book', '12.49')
        tax = calculator.calculate(item)

        expect(tax).to eq(BigDecimal('0'))
      end

      it 'exempts food from basic sales tax' do
        item = LineItem.new(1, 'chocolate bar', '0.85')
        tax = calculator.calculate(item)

        expect(tax).to eq(BigDecimal('0'))
      end

      it 'exempts medical products from basic sales tax' do
        item = LineItem.new(1, 'packet of headache pills', '9.75')
        tax = calculator.calculate(item)

        expect(tax).to eq(BigDecimal('0'))
      end

      it 'applies import duty to exempt categories' do
        item = LineItem.new(1, 'imported box of chocolates', '10.00')
        tax = calculator.calculate(item)

        # Food is exempt from sales tax, but still pays import duty
        # 10.00 * 0.05 = 0.50
        expect(tax).to eq(BigDecimal('0.50'))
      end
    end

    context 'combined taxes for imported non-exempt items' do
      it 'calculates both basic sales tax and import duty for imported perfume' do
        item = LineItem.new(1, 'imported bottle of perfume', '47.50')
        tax = calculator.calculate(item)

        # Basic: 47.50 * 0.10 = 4.75 (rounds to 4.75)
        # Import: 47.50 * 0.05 = 2.375 (rounds to 2.40)
        # Total: 4.75 + 2.40 = 7.15
        expect(tax).to eq(BigDecimal('7.15'))
      end
    end

    context 'quantity handling' do
      it 'multiplies tax by quantity for multiple books (tax-exempt)' do
        item = LineItem.new(2, 'book', '12.49')
        tax = calculator.calculate(item)

        # Books are exempt, so tax is 0 regardless of quantity
        expect(tax).to eq(BigDecimal('0'))
      end

      it 'multiplies tax by quantity for multiple items' do
        item = LineItem.new(3, 'imported boxes of chocolates', '11.25')
        tax = calculator.calculate(item)

        # Per unit: 11.25 * 0.05 = 0.5625 (rounds to 0.60)
        # Total: 0.60 * 3 = 1.80
        expect(tax).to eq(BigDecimal('1.80'))
      end

      it 'calculates correctly for quantity of 2 on taxable item' do
        item = LineItem.new(2, 'music CD', '14.99')
        tax = calculator.calculate(item)

        # Per unit: 14.99 * 0.10 = 1.499 (rounds to 1.50)
        # Total: 1.50 * 2 = 3.00
        expect(tax).to eq(BigDecimal('3.00'))
      end
    end

    context 'rounding behavior' do
      it 'rounds 1.499 up to 1.50' do
        item = LineItem.new(1, 'music CD', '14.99')
        tax = calculator.calculate(item)

        # 14.99 * 0.10 = 1.499 → 1.50
        expect(tax).to eq(BigDecimal('1.50'))
      end

      it 'rounds 2.375 up to 2.40' do
        # We need an item that produces 2.375 in tax
        # 47.50 * 0.05 = 2.375
        item = LineItem.new(1, 'imported book', '47.50')
        tax = calculator.calculate(item)

        # 47.50 * 0.05 = 2.375 → 2.40
        expect(tax).to eq(BigDecimal('2.40'))
      end

      it 'keeps 4.20 as 4.20 (already at 0.05 boundary)' do
        item = LineItem.new(1, 'imported bottle of perfume', '27.99')
        tax = calculator.calculate(item)

        # Basic: 27.99 * 0.10 = 2.799 → 2.80
        # Import: 27.99 * 0.05 = 1.3995 → 1.40
        # Total: 2.80 + 1.40 = 4.20
        expect(tax).to eq(BigDecimal('4.20'))
      end

      it 'rounds very small tax amounts correctly' do
        item = LineItem.new(1, 'music CD', '0.99')
        tax = calculator.calculate(item)

        # 0.99 * 0.10 = 0.099 → 0.10
        expect(tax).to eq(BigDecimal('0.10'))
      end
    end
  end
end
