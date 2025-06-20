module NutrientCalculator
  module InputProcessing
    class WeightStatusCategorizationService
      def self.categorize(bmi, age_years)
        return :invalid if bmi.nil? || bmi <= 0

        if age_years < 2
          :not_applicable
        elsif age_years < 20
          categorize_child_bmi(bmi, age_years)
        else
          categorize_adult_bmi(bmi)
        end
      end

      private

      def self.categorize_adult_bmi(bmi)
        case bmi
        when 0..18.5
          :underweight
        when 18.5..25
          :normal_weight
        when 25..30
          :overweight
        else
          :obese
        end
      end

      def self.categorize_child_bmi(bmi, age_years)
        # For children, we would need CDC growth charts
        # This is a simplified version - in practice, you'd want to use
        # the actual CDC growth chart percentiles
        case bmi
        when 0..5
          :underweight
        when 5..85
          :normal_weight
        when 85..95
          :overweight
        else
          :obese
        end
      end
    end
  end
end
