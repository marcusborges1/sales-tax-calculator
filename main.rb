require_relative 'lib/input_parser'

# Accepts filename as argument of default to 'fixtures/basic_items.txt'
# Example: ruby main.rb fixtures/imported_items.txt
filename = ARGV[0] || 'fixtures/basic_items.txt'

# Temporarily showing only parsing
items = InputParser.parse_file(filename)
items.each do |item|
  puts "#{item.quantity} #{item.name} - #{'%.2f' % item.unit_price}"
end
