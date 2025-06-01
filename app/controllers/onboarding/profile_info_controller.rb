class Onboarding::ProfileInfoController < Onboarding::BaseController
  def show
    @profile = onboarding_profile
  end

  def update
    @profile = OnboardingProfile.new(profile_info_params)
    update_onboarding_profile(profile_info_params)
    redirect_to next_step
  end

  def back
    redirect_to previous_step
  end

  private

  def profile_info_params
    params.require(:onboarding_profile).permit(:name, :email, :zip_code, :country_code, :state_code, :age, :sex, :height, :weight, :activity_level, :pregnancy_status, :lactation_status)
  end
end
