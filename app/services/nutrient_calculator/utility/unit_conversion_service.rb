module NutrientCalculator
  module Utility
    class UnitConversionService
      # Weight conversions
      def self.lbs_to_kg(lbs)
        lbs * 0.45359237
      end

      def self.kg_to_lbs(kg)
        kg / 0.45359237
      end

      # Length conversions
      def self.inches_to_cm(inches)
        inches * 2.54
      end

      def self.cm_to_inches(cm)
        cm / 2.54
      end

      # Vitamin A conversions (IU to µg RAE)
      def self.iu_to_ug_rae(iu, source_type)
        case source_type
        when :retinol
          iu * 0.3
        when :beta_carotene
          iu * 0.05
        when :other_carotenoids
          iu * 0.025
        else
          raise ArgumentError, "Invalid source type for Vitamin A conversion"
        end
      end

      def self.ug_rae_to_iu(ug_rae, source_type)
        case source_type
        when :retinol
          ug_rae / 0.3
        when :beta_carotene
          ug_rae / 0.05
        when :other_carotenoids
          ug_rae / 0.025
        else
          raise ArgumentError, "Invalid source type for Vitamin A conversion"
        end
      end
    end
  end
end
