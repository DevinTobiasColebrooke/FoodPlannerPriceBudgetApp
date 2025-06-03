module NutrientCalculator
  class VitaminAService < BaseMicronutrientService
    def initialize(user_input_dto, dri_lookup)
      super(user_input_dto, dri_lookup, Nutrient.find_by(name: 'Vitamin A'))
    end

    def calculate
      base_calculation = super
      base_calculation.merge(
        rae_conversion: calculate_rae_conversion,
        beta_carotene_conversion: calculate_beta_carotene_conversion
      )
    end

    private

    def calculate_rae_conversion
      {
        retinol: 1,
        beta_carotene: 12,
        other_carotenoids: 24
      }
    end

    def calculate_beta_carotene_conversion
      {
        from_iu: 0.3,
        to_iu: 3.33
      }
    end
  end
end
