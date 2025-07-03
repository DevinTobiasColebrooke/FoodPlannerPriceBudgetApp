module NutrientCalculator
  module DataContracts
    module Inputs
      class UserInputDto
        attr_reader :age_in_months, :age_years, :sex, :height_cm, :weight_kg, :physical_activity_level,
                    :is_pregnant, :pregnancy_trimester, :gestational_weeks,
                    :is_lactating, :lactation_period,
                    :is_smoker, :is_vegetarian_or_vegan,
                    :pre_pregnancy_weight_kg

        def initialize(attributes = {})
          @age_in_months = attributes[:age_in_months]
          raise ArgumentError, 'age_in_months is required' unless @age_in_months

          @age_years = @age_in_months / 12.0
          @sex = attributes[:sex]&.to_sym
          @height_cm = attributes[:height_cm]
          @weight_kg = attributes[:weight_kg]
          @physical_activity_level = attributes[:physical_activity_level]&.to_sym

          @is_pregnant = attributes.fetch(:is_pregnant, false)
          @pregnancy_trimester = attributes[:pregnancy_trimester]
          @gestational_weeks = attributes[:gestational_weeks] # Must be passed in if pregnant

          @is_lactating = attributes.fetch(:is_lactating, false)
          @lactation_period = attributes[:lactation_period]&.to_sym

          @is_smoker = attributes.fetch(:is_smoker, false)
          @is_vegetarian_or_vegan = attributes.fetch(:is_vegetarian_or_vegan, false)

          # Assume pre_pregnancy_weight_kg is passed if relevant, otherwise default to current weight
          @pre_pregnancy_weight_kg = attributes[:pre_pregnancy_weight_kg] || @weight_kg
        end

        def is_smoker?
          @is_smoker
        end

        def is_pregnant?
          @is_pregnant
        end

        def is_lactating?
          @is_lactating
        end

        def pregnancy_status
          @is_pregnant ? @pregnancy_trimester : nil
        end

        def lactation_status
          @is_lactating ? @lactation_period : nil
        end

        def is_vegetarian_or_vegan?
          @is_vegetarian_or_vegan
        end
      end
    end
  end
end
