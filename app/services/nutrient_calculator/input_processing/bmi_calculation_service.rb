module NutrientCalculator
  module InputProcessing
    class BmiCalculationService
      def initialize(user_input_dto)
        @user_input = user_input_dto
      end

      def calculate
        calculate_with_weight(@user_input.weight_kg)
      end

      def calculate_with_weight(weight_kg)
        return nil unless @user_input.height_cm && weight_kg && @user_input.height_cm > 0

        height_m = @user_input.height_cm / 100.0
        bmi = (weight_kg / (height_m**2)).round(1)

        {
          value: bmi,
          category: WeightStatusCategorizationService.categorize(bmi, @user_input.age_years)
        }
      end
    end
  end
end
