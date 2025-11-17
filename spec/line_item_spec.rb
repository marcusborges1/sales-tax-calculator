# frozen_string_literal: true

require 'spec_helper'
require 'bigdecimal'
require_relative '../lib/line_item'

RSpec.describe LineItem do
  describe '#initialize' do
    it 'stores quantity' do
      item = described_class.new(2, 'book', '12.49')
      expect(item.quantity).to eq(2)
    end

    it 'stores name' do
      item = described_class.new(1, 'chocolate bar', '0.85')
      expect(item.name).to eq('chocolate bar')
    end

    it 'stores unit_price as BigDecimal' do
      item = described_class.new(1, 'music CD', '14.99')
      expect(item.unit_price).to eq(BigDecimal('14.99'))
      expect(item.unit_price).to be_a(BigDecimal)
    end

    it 'stores category' do
      item = described_class.new(1, 'headache pills', '9.75')
      expect(item.category).to eq(:medical)
    end

    it 'stores imported status' do
      item = described_class.new(1, 'imported perfume', '27.99')
      expect(item.imported).to be(true)
    end

    describe 'quantity validation' do
      it 'raises ArgumentError when quantity is zero' do
        expect { described_class.new(0, 'book', '12.49') }
          .to raise_error(ArgumentError, 'quantity must be positive')
      end

      it 'raises ArgumentError when quantity is negative' do
        expect { described_class.new(-1, 'book', '12.49') }
          .to raise_error(ArgumentError, 'quantity must be positive')
      end
    end

    describe 'name validation' do
      it 'raises ArgumentError when name is empty' do
        expect { described_class.new(1, '', '12.49') }
          .to raise_error(ArgumentError, 'name cannot be empty')
      end

      it 'raises ArgumentError when name is only whitespace' do
        expect { described_class.new(1, '   ', '12.49') }
          .to raise_error(ArgumentError, 'name cannot be empty')
      end

      it 'raises ArgumentError when name is only tabs' do
        expect { described_class.new(1, "\t\t", '12.49') }
          .to raise_error(ArgumentError, 'name cannot be empty')
      end
    end

    describe 'unit_price validation' do
      it 'raises ArgumentError when unit_price is zero' do
        expect { described_class.new(1, 'book', '0') }
          .to raise_error(ArgumentError, 'unit_price must be positive')
      end

      it 'raises ArgumentError when unit_price is negative' do
        expect { described_class.new(1, 'book', '-5.00') }
          .to raise_error(ArgumentError, 'unit_price must be positive')
      end

      it 'raises ArgumentError when unit_price is negative number' do
        expect { described_class.new(1, 'book', -10) }
          .to raise_error(ArgumentError, 'unit_price must be positive')
      end
    end
  end

  describe '#base_total_price' do
    context 'when quantity is 1' do
      it 'returns the unit price' do
        item = described_class.new(1, 'book', '12.49')
        expect(item.base_total_price).to eq(BigDecimal('12.49'))
      end
    end

    context 'when quantity is greater than 1' do
      it 'returns quantity multiplied by unit price' do
        item = described_class.new(2, 'book', '12.49')
        expect(item.base_total_price).to eq(BigDecimal('24.98'))
      end

      it 'calculates correctly for quantity of 3' do
        item = described_class.new(3, 'imported boxes of chocolates', '11.25')
        expect(item.base_total_price).to eq(BigDecimal('33.75'))
      end
    end
  end

  describe '#tax_exempt?' do
    context 'when category is exempt' do
      it 'returns true for books' do
        item = described_class.new(1, 'book', '12.49')
        expect(item.tax_exempt?).to be(true)
      end

      it 'returns true for food' do
        item = described_class.new(1, 'chocolate bar', '0.85')
        expect(item.tax_exempt?).to be(true)
      end

      it 'returns true for medical products' do
        item = described_class.new(1, 'headache pills', '9.75')
        expect(item.tax_exempt?).to be(true)
      end
    end

    context 'when category is not exempt' do
      it 'returns false for other category' do
        item = described_class.new(1, 'music CD', '14.99')
        expect(item.tax_exempt?).to be(false)
      end

      it 'returns false for perfume' do
        item = described_class.new(1, 'bottle of perfume', '18.99')
        expect(item.tax_exempt?).to be(false)
      end
    end
  end

  describe '#imported?' do
    context 'when item is imported' do
      it 'returns true for imported items' do
        item = described_class.new(1, 'imported bottle of perfume', '27.99')
        expect(item.imported?).to be(true)
      end

      it 'returns true for imported food' do
        item = described_class.new(1, 'imported box of chocolates', '10.00')
        expect(item.imported?).to be(true)
      end
    end

    context 'when item is not imported' do
      it 'returns false for domestic items' do
        item = described_class.new(1, 'book', '12.49')
        expect(item.imported?).to be(false)
      end

      it 'returns false for domestic perfume' do
        item = described_class.new(1, 'bottle of perfume', '18.99')
        expect(item.imported?).to be(false)
      end
    end
  end
end
