module NutrientCalculator
  module Utility
    class ReferenceBodyDataService
      def self.get_reference_weight(age_years, sex)
        case sex
        when :male
          case age_years
          when 0..0.5
            7.0
          when 0.5..1
            9.0
          when 1..3
            13.0
          when 4..8
            22.0
          when 9..13
            40.0
          when 14..18
            64.0
          when 19..30
            70.0
          when 31..50
            70.0
          when 51..70
            70.0
          else
            70.0
          end
        when :female
          case age_years
          when 0..0.5
            7.0
          when 0.5..1
            9.0
          when 1..3
            13.0
          when 4..8
            22.0
          when 9..13
            40.0
          when 14..18
            54.0
          when 19..30
            57.0
          when 31..50
            57.0
          when 51..70
            57.0
          else
            57.0
          end
        end
      end

      def self.get_reference_height(age_years, sex)
        case sex
        when :male
          case age_years
          when 0..0.5
            67.0
          when 0.5..1
            75.0
          when 1..3
            95.0
          when 4..8
            120.0
          when 9..13
            150.0
          when 14..18
            176.0
          when 19..30
            178.0
          when 31..50
            178.0
          when 51..70
            178.0
          else
            178.0
          end
        when :female
          case age_years
          when 0..0.5
            67.0
          when 0.5..1
            75.0
          when 1..3
            95.0
          when 4..8
            120.0
          when 9..13
            150.0
          when 14..18
            163.0
          when 19..30
            163.0
          when 31..50
            163.0
          when 51..70
            163.0
          else
            163.0
          end
        end
      end

      def self.get_age_group(age_years)
        case age_years
        when 0..0.5
          :infant_0_6_months
        when 0.5..1
          :infant_7_12_months
        when 1..3
          :child_1_3_years
        when 4..8
          :child_4_8_years
        when 9..13
          :child_9_13_years
        when 14..18
          :adolescent_14_18_years
        when 19..30
          :adult_19_30_years
        when 31..50
          :adult_31_50_years
        when 51..70
          :adult_51_70_years
        else
          :adult_over_70_years
        end
      end
    end
  end
end
