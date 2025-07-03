class Onboarding::ShoppingController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    if update_onboarding_profile(shopping_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def shopping_params
    params.require(:onboarding_profile).permit(
      :shopping_difficulty,
      :weekly_budget,
      :budget_flexible,
      :location_type,
      :region_zip
    ).transform_keys do |key|
      case key
      when 'shopping_difficulty'
        'shopping_difficulty_preference'
      when 'weekly_budget'
        'weekly_budget_amount'
      when 'budget_flexible'
        'budget_is_flexible'
      when 'location_type'
        'location_preference_type'
      when 'region_zip'
        'zip_code'
      else
        key
      end
    end.tap do |params|
      # Convert types to match OnboardingProfile attributes
      params['weekly_budget_amount'] = params['weekly_budget_amount'].to_d if params['weekly_budget_amount'].present?
      params['budget_is_flexible'] = ActiveModel::Type::Boolean.new.cast(params['budget_is_flexible']) if params['budget_is_flexible'].present?
    end
  end
end
