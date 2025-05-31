class Onboarding::ProfileInfoController < Onboarding::BaseController
  def show
    @profile = onboarding_profile
  end

  def update
    if update_onboarding_profile(profile_info_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      render :show, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def profile_info_params
    params.require(:onboarding_profile).permit(:name, :email, :zip_code, :country_code, :state_code, :age, :sex, :height, :weight, :activity_level, :pregnancy_status, :lactation_status)
  end
end
