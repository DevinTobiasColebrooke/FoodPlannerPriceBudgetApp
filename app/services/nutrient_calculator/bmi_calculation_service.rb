module NutrientCalculator
  class BmiCalculationService
    def initialize(user_input_dto)
      @user_input = user_input_dto
    end

    def calculate
      return nil unless @user_input.height_cm && @user_input.weight_kg

      weight_kg = @user_input.weight_kg
      height_m = @user_input.height_cm / 100.0

      bmi = (weight_kg / (height_m * height_m)).round(1)

      {
        value: bmi,
        category: determine_weight_status(bmi)
      }
    end

    private

    def determine_weight_status(bmi)
      return nil unless bmi

      case
      when bmi < 18.5
        'Underweight'
      when bmi < 25
        'Normal weight'
      when bmi < 30
        'Overweight'
      else
        'Obese'
      end
    end
  end
end
