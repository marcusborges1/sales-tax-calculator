# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'bigdecimal'
require_relative '../lib/input_parser'

RSpec.describe InputParser do
  describe '.parse_file' do
    let(:temp_file) { Tempfile.new(['test_input', '.txt']) }

    after { temp_file.unlink }

    it 'returns a list with multiple line items' do
      content = <<~INPUT
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT

      temp_file.write(content)
      temp_file.rewind

      line_items = described_class.parse_file(temp_file.path)

      expect(line_items.length).to eq(3)
      expect(line_items[0].name).to eq('book')
      expect(line_items[1].name).to eq('music CD')
      expect(line_items[2].name).to eq('chocolate bar')
    end

    it 'parses imported property properly' do
      content = <<~INPUT
        1 imported box of chocoaltes at 10.00
        1 imported bottle of perfume at 47.50
      INPUT

      temp_file.write(content)
      temp_file.rewind

      line_items = described_class.parse_file(temp_file.path)

      expect(line_items.length).to eq(2)
      expect(line_items[0].imported).to be(true)
      expect(line_items[1].imported).to be(true)
    end

    it 'parses categories property properly' do
      content = <<~INPUT
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT

      temp_file.write(content)
      temp_file.rewind

      line_items = described_class.parse_file(temp_file.path)

      expect(line_items.length).to eq(3)
      expect(line_items[0].category).to eq(:book)
      expect(line_items[1].category).to eq(:other)
      expect(line_items[2].category).to eq(:food)
    end

    it 'returns empty list for empty file' do
      temp_file.write('')
      temp_file.rewind

      line_items = described_class.parse_file(temp_file.path)

      expect(line_items).to be_empty
    end

    it 'handles files with empty lines gracefully' do
      content = <<~INPUT
        2 book at 12.49

        1 music CD at 14.99

        1 chocolate bar at 0.85
      INPUT

      temp_file.write(content)
      temp_file.rewind

      line_items = described_class.parse_file(temp_file.path)

      expect(line_items.length).to eq(3)
      expect(line_items[0].name).to eq('book')
      expect(line_items[1].name).to eq('music CD')
      expect(line_items[2].name).to eq('chocolate bar')
    end

    it 'raises an Errno::ENOENT error when file does not exist' do
      expect { described_class.parse_file('non-existent-path') }.to(raise_error { Errno::ENOENT })
    end
  end

  describe '.parse_line' do
    it 'parses a basic book line' do
      line = '2 book at 12.49'
      item = described_class.parse_line(line)

      expect(item.quantity).to eq(2)
      expect(item.name).to eq('book')
      expect(item.unit_price).to eq(BigDecimal('12.49'))
      expect(item.category).to eq(:book)
      expect(item.imported).to be(false)
    end

    it 'parses an imported bottle of perfume' do
      line = '1 imported bottle of perfume at 47.50'
      item = described_class.parse_line(line)

      expect(item.quantity).to eq(1)
      expect(item.name).to eq('imported bottle of perfume')
      expect(item.unit_price).to eq(BigDecimal('47.50'))
      expect(item.category).to eq(:other)
      expect(item.imported).to be(true)
    end

    it 'raises an ArgumentError when line is not on expected pattern' do
      line = 'anything outside of our expected pattern'

      expect { described_class.parse_line(line) }.to raise_error(ArgumentError)
    end
  end
end
