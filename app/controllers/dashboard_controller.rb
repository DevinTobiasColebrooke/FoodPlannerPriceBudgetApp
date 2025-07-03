class DashboardController < ApplicationController
  layout 'mobile'

  def show
    @current_user = Current.session.user

    # Get user input data from either current user or session/onboarding profile
    user_input_attributes = if @current_user
      {
        age_in_months: @current_user.age_in_months,
        sex: @current_user.sex,
        height_cm: @current_user.height_cm,
        weight_kg: @current_user.weight_kg,
        physical_activity_level: @current_user.physical_activity_level,
        is_pregnant: @current_user.is_pregnant?,
        pregnancy_trimester: @current_user.pregnancy_trimester,
        is_lactating: @current_user.is_lactating?,
        lactation_period: @current_user.lactation_period
      }
    else
      # Get data from session or onboarding profile
      onboarding_profile = session[:onboarding_profile] || {}
      age_in_years = onboarding_profile['age']
      {
        age_in_months: age_in_years.present? ? age_in_years.to_i * 12 : nil,
        sex: onboarding_profile['sex'],
        height_cm: onboarding_profile['height'],
        weight_kg: onboarding_profile['weight'],
        physical_activity_level: onboarding_profile['activity_level'],
        is_pregnant: ActiveModel::Type::Boolean.new.cast(onboarding_profile['pregnancy_status']),
        pregnancy_trimester: onboarding_profile['pregnancy_trimester'],
        is_lactating: ActiveModel::Type::Boolean.new.cast(onboarding_profile['lactation_status']),
        lactation_period: onboarding_profile['lactation_period']
      }
    end

    # Only calculate if we have the minimum required data
    if user_input_attributes[:age_in_months].present? &&
       user_input_attributes[:height_cm].present? &&
       user_input_attributes[:weight_kg].present?
      user_input_dto = NutrientCalculator::DataContracts::Inputs::UserInputDto.new(user_input_attributes)
      @nutrient_calculation = NutrientCalculator::Orchestration::NutrientCalculatorService.new(user_input_dto).calculate

      # LOGGING: See the final calculation result in the controller
      Rails.logger.debug "########### DASHBOARD CONTROLLER ###########"
      Rails.logger.debug "Nutrient Calculation Result: #{@nutrient_calculation.inspect}"
      Rails.logger.debug "##########################################"
    end
  end
end
