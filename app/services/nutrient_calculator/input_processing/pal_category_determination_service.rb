module NutrientCalculator
  class PalCategoryDeterminationService
    PAL_CATEGORIES = {
      sedentary: 1.0..1.39,
      low_active: 1.4..1.59,
      active: 1.6..1.89,
      very_active: 1.9..2.5
    }.freeze

    def initialize(activity_data)
      @activity_data = activity_data
    end

    def determine_category
      pal_value = calculate_pal_value
      PAL_CATEGORIES.find { |_category, range| range.include?(pal_value) }&.first || :sedentary
    end

    private

    def calculate_pal_value
      # Calculate PAL based on activity data
      # This is a simplified implementation
      # In reality, this would analyze detailed activity logs
      base_pal = 1.2 # Base sedentary value

      # Add PAL points based on activity data
      base_pal += calculate_activity_points

      # Cap at maximum PAL value
      [base_pal, 2.5].min
    end

    def calculate_activity_points
      points = 0.0

      # Example activity point calculation
      # In reality, this would be more complex based on activity logs
      if @activity_data[:daily_steps]&.positive?
        points += (@activity_data[:daily_steps].to_f / 10000) * 0.1
      end

      if @activity_data[:exercise_minutes]&.positive?
        points += (@activity_data[:exercise_minutes].to_f / 60) * 0.2
      end

      points
    end
  end
end
