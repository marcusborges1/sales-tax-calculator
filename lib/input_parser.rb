require_relative 'line_item'

class InputParser
    CATEGORY_KEYWORDS = {
        book: %w[book books],
        food: %w[chocolate chocolates bar cake cakes candy candies],
        medical: %w[pill pills medicine headache]
    }

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

        category = determine_category(name)
        imported = name.include?("imported")

        LineItem.new(quantity, name, price, category, imported)
    end

    def self.determine_category(name)
      clean_name = name.gsub(/^imported\s+/, '').downcase

      CATEGORY_KEYWORDS.each do |category, keywords|
        return category if keywords.any? { |kw| clean_name.include?(kw) }
      end

      :other
    end
end