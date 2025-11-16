require_relative 'line_item'

class InputParser
    def self.parse_file(filename)
        File.readlines(filename).map do |line|
           parse_line(line.strip)
        end
    end

    def self.parse_line(line)
        match = line.match(/^(\d+)\s+(.+)\s+at\s+([\d.]+)$/)

        quantity = match[1].to_i
        name = match[2]
        price = match[3]

        LineItem.new(quantity, name, price)
    end
end