# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'fileutils'

RSpec.describe 'End-to-end Test' do
  let(:main_script) { File.expand_path('../main.rb', __dir__) }

  describe 'runing main.rb with fixture files' do
    context 'with basic_items.txt' do
      it 'produces correct receipt output' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script} fixtures/basic_items.txt")

        expect(status.success?).to be(true)
        expect(stderr).to be_empty
        expect(stdout).to eq(
          <<~OUTPUT
            2 book: 24.98
            1 music CD: 16.49
            1 chocolate bar: 0.85
            Sales Taxes: 1.50
            Total: 42.32
          OUTPUT
        )
      end
    end

    context 'with imported_items.txt' do
      it 'produces correct receipt output' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script} fixtures/imported_items.txt")

        expect(status.success?).to be(true)
        expect(stderr).to be_empty
        expect(stdout).to eq(
          <<~OUTPUT
            1 imported box of chocolates: 10.50
            1 imported bottle of perfume: 54.65
            Sales Taxes: 7.65
            Total: 65.15
          OUTPUT
        )
      end
    end

    context 'with mixed_items.txt' do
      it 'produces correct receipt output' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script} fixtures/mixed_items.txt")

        expect(status.success?).to be(true)
        expect(stderr).to be_empty
        expect(stdout).to eq(
          <<~OUTPUT
            1 imported bottle of perfume: 32.19
            1 bottle of perfume: 20.89
            1 packet of headache pills: 9.75
            3 imported boxes of chocolates: 35.55
            Sales Taxes: 7.90
            Total: 98.38
          OUTPUT
        )
      end
    end

    context 'with default fixture (no argument)' do
      it 'uses basic_items.txt by default' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script}")

        expect(status.success?).to be(true)
        expect(stderr).to be_empty
        expect(stdout).to eq(
          <<~OUTPUT
            2 book: 24.98
            1 music CD: 16.49
            1 chocolate bar: 0.85
            Sales Taxes: 1.50
            Total: 42.32
          OUTPUT
        )
      end
    end

    context 'with non-existent file' do
      it 'handles error gracefully' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script} nonexistent.txt")

        expect(status.success?).to be(false)
        expect(stderr).to be_empty
        expect(stdout).to include('Error: File')
      end
    end

    context 'with malformed input file' do
      let(:temp_file) { 'fixtures/temp_malformed.txt' }

      before do
        File.write(temp_file, "invalid line format\n")
      end

      after do
        FileUtils.rm_f(temp_file)
      end

      it 'handles parsing errors gracefully' do
        stdout, stderr, status = Open3.capture3("ruby #{main_script} #{temp_file}")

        expect(status.success?).to be(false)
        expect(stderr).to be_empty
        expect(stdout).to include('Error: Invalid input format')
      end
    end
  end
end
