# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/sales_tax_report'

RSpec.describe SalesTaxReport do
  describe '#print' do
    context 'basic items' do
      it 'prints taxes report to stdout' do
        items = [
          { quantity: 2, name: 'book', price_with_tax: BigDecimal('24.98') },
          { quantity: 1, name: 'music CD', price_with_tax: BigDecimal('16.49') },
          { quantity: 1, name: 'chocolate bar', price_with_tax: BigDecimal('0.85') }
        ]
        sales_taxes = BigDecimal('1.50')
        total = BigDecimal('42.32')

        report = described_class.new(items, sales_taxes, total)

        expect { report.print }.to output(
          <<~OUTPUT
            2 book: 24.98
            1 music CD: 16.49
            1 chocolate bar: 0.85
            Sales Taxes: 1.50
            Total: 42.32
          OUTPUT
        ).to_stdout
      end
    end

    context 'imported items' do
      it 'prints taxes report to stdout' do
        items = [
          { quantity: 1, name: 'imported box of chocolates', price_with_tax: BigDecimal('10.50') },
          { quantity: 1, name: 'imported bottle of perfume', price_with_tax: BigDecimal('54.65') }
        ]
        sales_taxes = BigDecimal('7.65')
        total = BigDecimal('65.15')

        report = described_class.new(items, sales_taxes, total)

        expect { report.print }.to output(
          <<~OUTPUT
            1 imported box of chocolates: 10.50
            1 imported bottle of perfume: 54.65
            Sales Taxes: 7.65
            Total: 65.15
          OUTPUT
        ).to_stdout
      end
    end

    context 'mixed items' do
      it 'prints taxes report to stdout' do
        items = [
          { quantity: 1, name: 'imported bottle of perfume', price_with_tax: BigDecimal('32.19') },
          { quantity: 1, name: 'bottle of perfume', price_with_tax: BigDecimal('20.89') },
          { quantity: 1, name: 'packet of headache pills', price_with_tax: BigDecimal('9.75') },
          { quantity: 3, name: 'imported boxes of chocolates', price_with_tax: BigDecimal('35.55') }
        ]
        sales_taxes = BigDecimal('7.90')
        total = BigDecimal('98.38')

        report = described_class.new(items, sales_taxes, total)

        expect { report.print }.to output(
          <<~OUTPUT
            1 imported bottle of perfume: 32.19
            1 bottle of perfume: 20.89
            1 packet of headache pills: 9.75
            3 imported boxes of chocolates: 35.55
            Sales Taxes: 7.90
            Total: 98.38
          OUTPUT
        ).to_stdout
      end
    end
  end
end
