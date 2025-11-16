# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/receipt'
require_relative '../lib/line_item'

RSpec.describe Receipt do
  describe '#evaluate' do
    context 'basic items' do
      it 'returns a SalesTaxReport with correct calculations' do
        line_items = [
          LineItem.new(2, 'book', '12.49'),
          LineItem.new(1, 'music CD', '14.99'),
          LineItem.new(1, 'chocolate bar', '0.85')
        ]
        receipt = described_class.new(line_items)
        report = receipt.evaluate

        expect(report).to be_a(SalesTaxReport)
        expect(report.items).to eq([
                                     { quantity: 2, name: 'book', price_with_tax: BigDecimal('24.98') },
                                     { quantity: 1, name: 'music CD', price_with_tax: BigDecimal('16.49') },
                                     { quantity: 1, name: 'chocolate bar', price_with_tax: BigDecimal('0.85') }
                                   ])
        expect(report.sales_taxes).to eq(BigDecimal('1.50'))
        expect(report.total).to eq(BigDecimal('42.32'))
      end
    end

    context 'imported items' do
      it 'returns a SalesTaxReport with correct calculations' do
        line_items = [
          LineItem.new(1, 'imported box of chocolates', '10.00'),
          LineItem.new(1, 'imported bottle of perfume', '47.50')
        ]
        receipt = described_class.new(line_items)
        report = receipt.evaluate

        expect(report).to be_a(SalesTaxReport)
        expect(report.items).to eq([
                                     { quantity: 1, name: 'imported box of chocolates',
                                       price_with_tax: BigDecimal('10.50') },
                                     { quantity: 1, name: 'imported bottle of perfume',
                                       price_with_tax: BigDecimal('54.65') }
                                   ])
        expect(report.sales_taxes).to eq(BigDecimal('7.65'))
        expect(report.total).to eq(BigDecimal('65.15'))
      end
    end

    context 'mixed items' do
      it 'returns a SalesTaxReport with correct calculations' do
        line_items = [
          LineItem.new(1, 'imported bottle of perfume', '27.99'),
          LineItem.new(1, 'bottle of perfume', '18.99'),
          LineItem.new(1, 'packet of headache pills', '9.75'),
          LineItem.new(3, 'imported boxes of chocolates', '11.25')
        ]
        receipt = described_class.new(line_items)
        report = receipt.evaluate

        expect(report).to be_a(SalesTaxReport)
        expect(report.items).to eq([
                                     { quantity: 1, name: 'imported bottle of perfume',
                                       price_with_tax: BigDecimal('32.19') },
                                     { quantity: 1, name: 'bottle of perfume', price_with_tax: BigDecimal('20.89') },
                                     { quantity: 1, name: 'packet of headache pills',
                                       price_with_tax: BigDecimal('9.75') },
                                     { quantity: 3, name: 'imported boxes of chocolates',
                                       price_with_tax: BigDecimal('35.55') }
                                   ])
        expect(report.sales_taxes).to eq(BigDecimal('7.90'))
        expect(report.total).to eq(BigDecimal('98.38'))
      end
    end
  end
end
