# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/receipt'

RSpec.describe Receipt do
  describe '#evaluate' do
    context 'basic items' do
      it 'prints taxes report to stdout' do
        line_items = [
          LineItem.new(2, 'book', '12.49', :book, false),
          LineItem.new(1, 'music CD', '14.99', :other, false),
          LineItem.new(1, 'chocolate bar', '0.85', :food, false)
        ]
        receipt = described_class.new(line_items)

        expect { receipt.evaluate }.to output(
          <<~INPUT
            2 book: 24.98
            1 music CD: 16.49
            1 chocolate bar: 0.85
            Sales Taxes: 1.50
            Total: 42.32
          INPUT
        ).to_stdout
      end
    end

    context 'imported items' do
      it 'prints taxes report to stdout' do
        line_items = [
          LineItem.new(1, 'imported box of chocolates', '10.00', :food, true),
          LineItem.new(1, 'imported bottle of perfume', '47.50', :other, true)
        ]
        receipt = described_class.new(line_items)

        expect { receipt.evaluate }.to output(
          <<~INPUT
            1 imported box of chocolates: 10.50
            1 imported bottle of perfume: 54.65
            Sales Taxes: 7.65
            Total: 65.15
          INPUT
        ).to_stdout
      end
    end

    context 'mixed items' do
      it 'prints taxes report to stdout' do
        line_items = [
          LineItem.new(1, 'imported bottle of perfume', '27.99', :other, true),
          LineItem.new(1, 'bottle of perfume', '18.99', :other, false),
          LineItem.new(1, 'packet of headache pills', '9.75', :medical, false),
          LineItem.new(3, 'imported boxes of chocolates', '11.25', :food, true)
        ]
        receipt = described_class.new(line_items)

        expect { receipt.evaluate }.to output(
          <<~INPUT
            1 imported bottle of perfume: 32.19
            1 bottle of perfume: 20.89
            1 packet of headache pills: 9.75
            3 imported boxes of chocolates: 35.55
            Sales Taxes: 7.90
            Total: 98.38
          INPUT
        ).to_stdout
      end
    end
  end
end
