require 'spec_helper'
require 'tempfile'
require 'bigdecimal'
require_relative '../lib/input_parser'

RSpec.describe InputParser do
    describe '.parse_file' do
        let(:temp_file) { Tempfile.new(['test_input', '.txt']) }
        after { temp_file.unlink }

        it 'returns a list with multiplee line items' do
            content = <<~INPUT
                2 book at 12.49
                1 music CD at 14.99
                1 chocolate bar at 0.85
            INPUT

            temp_file.write(content)
            temp_file.rewind

            line_items = InputParser.parse_file(temp_file.path)

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

            line_items = InputParser.parse_file(temp_file.path)

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

            line_items = InputParser.parse_file(temp_file.path)

            expect(line_items.length).to eq(3)
            expect(line_items[0].category).to eq(:book)
            expect(line_items[1].category).to eq(:other)
            expect(line_items[2].category).to eq(:food)
        end

        it 'returns empty list for empty file' do
          temp_file.write('')
          temp_file.rewind

          line_items = InputParser.parse_file(temp_file.path)

            expect(line_items).to be_empty
        end
    end

    describe '.parse_line' do
        it 'parses a basic book line' do
            line = "2 book at 12.49"
            item = InputParser.parse_line(line)

            expect(item.quantity).to eq(2)
            expect(item.name).to eq('book')
            expect(item.unit_price).to eq(BigDecimal('12.49'))
            expect(item.category).to eq(:book)
            expect(item.imported).to be(false)
        end

        it 'parses an imported bottle of perfume' do
            line = "1 imported bottle of perfume at 47.50"
            item = InputParser.parse_line(line)

            expect(item.quantity).to eq(1)
            expect(item.name).to eq('imported bottle of perfume')
            expect(item.unit_price).to eq(BigDecimal('47.50'))
            expect(item.category).to eq(:other)
            expect(item.imported).to be(true)
        end
    end

    describe '.determine_category' do
        context 'when product is a book' do
            it 'returns :book for "book"' do
                expect(InputParser.determine_category('book')).to eq(:book)
            end

            it 'returns :book for "books"' do
                expect(InputParser.determine_category('book')).to eq(:book)
            end

            it 'returns :book for "Book" (case insensitive)' do
                expect(InputParser.determine_category('book')).to eq(:book)
            end

            it 'returns :book for "imported book"' do
                expect(InputParser.determine_category('book')).to eq(:book)
            end
        end

        context 'when product is food' do
            it 'returns :food for "chocolate bar"' do
                expect(InputParser.determine_category('chocolate bar')).to eq(:food)
            end

            it 'returns :food for "box of chocolates"' do
                expect(InputParser.determine_category('box of chocolates')).to eq(:food)
            end

            it 'returns :food for "candy"' do
                expect(InputParser.determine_category('candy')).to eq(:food)
            end

            it 'returns :food for "cake"' do
                expect(InputParser.determine_category('cake')).to eq(:food)
            end

            it 'returns :food for "imported box of chocolates"' do
                expect(InputParser.determine_category('imported box of chocolates')).to eq(:food)
            end
        end

        context 'when product is medical' do
            it 'returns :medical for "headache pills"' do
                expect(InputParser.determine_category('headache pills')).to eq(:medical)
            end

            it 'returns :medicine for "medicine"' do
                expect(InputParser.determine_category('medicine')).to eq(:medical)
            end

            it 'returns :medicine for "pill"' do
                expect(InputParser.determine_category('medicine')).to eq(:medical)
            end
        end

        context 'when product is other' do
            it 'returns :other for "music CD"' do
                expect(InputParser.determine_category('music CD')).to eq(:other)
            end

            it 'returns :other for "bottle of perfume"' do
                expect(InputParser.determine_category('bottle of perfume')).to eq(:other)
            end

            it 'returns :other for unkown items' do
                expect(InputParser.determine_category('counter strike 2')).to eq(:other)
            end
        end
    end
end