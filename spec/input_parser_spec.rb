require 'spec_helper'
require 'tempfile'
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

        it 'parses properly imported products' do
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

        it 'returns empty list for empty file' do
          temp_file.write('')
          temp_file.rewind

          line_items = InputParser.parse_file(temp_file.path)

            expect(line_items).to be_empty
        end
    end
end