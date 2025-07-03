module Seeding
  module Helpers
    module AmountParser
      def self.parse_amount_value(value_str)
        return nil if value_str.blank?
        value_str = value_str.strip.gsub('"', '') # Remove quotes if any

        if value_str.include?('/') # fraction
          parts = value_str.split(' ')
          total = 0.0
          if parts.length > 1 # mixed number like "1 ¾"
            total += parts[0].to_f
            fraction_part = parts[1]
          else # simple fraction like "⅔"
            fraction_part = parts[0]
          end
          num, den = fraction_part.split('/').map(&:to_f)
          total += num / den if den && den != 0
          return total.round(4)
        elsif value_str.include?('-') && value_str.match?(/\d+-\d+/) # range like "2-3", ensure it's not part of a name
          # For ranges, DGA typically implies the lower bound or an average.
          # We'll take the lower bound.
          return value_str.split('-').first.to_f.round(4)
        else # simple number
          return value_str.to_f.round(4)
        end
      rescue StandardError => e
        puts "WARN: Could not parse amount_value '#{value_str}': #{e.message}. Returning nil."
        nil
      end
    end
  end
end
