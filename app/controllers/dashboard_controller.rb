class DashboardController < ApplicationController
  layout 'mobile'

  def show
    @current_user = Current.session.user

    # Get user input data from either current user or session/onboarding profile
    user_input_attributes = if @current_user
      {
        age_in_months: @current_user.age_in_months, # Already in months
        sex: @current_user.sex,
        height: @current_user.height_cm,
        weight: @current_user.weight_kg,
        activity_level: @current_user.physical_activity_level,
        pregnancy_status: @current_user.is_pregnant? ? @current_user.pregnancy_trimester : nil,
        lactation_status: @current_user.is_lactating? ? @current_user.lactation_period : nil
      }
    else
      # Get data from session or onboarding profile
      onboarding_profile = session[:onboarding_profile]
      {
        age: onboarding_profile&.dig('age'), # In years from onboarding
        sex: onboarding_profile&.dig('sex'),
        height: onboarding_profile&.dig('height'),
        weight: onboarding_profile&.dig('weight'),
        activity_level: onboarding_profile&.dig('activity_level'),
        pregnancy_status: onboarding_profile&.dig('pregnancy_status'),
        lactation_status: onboarding_profile&.dig('lactation_status')
      }
    end

    # Only calculate if we have the minimum required data
    if (user_input_attributes[:age_in_months].present? || user_input_attributes[:age].present?) &&
       user_input_attributes[:height].present? &&
       user_input_attributes[:weight].present?
      user_input_dto = NutrientCalculator::DataContracts::Inputs::UserInputDto.new(user_input_attributes)
      @nutrient_calculation = NutrientCalculator::Orchestration::NutrientCalculatorService.new(user_input_dto).calculate
    end
  end
end
