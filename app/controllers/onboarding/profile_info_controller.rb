class Onboarding::ProfileInfoController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    update_onboarding_profile(profile_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_goal_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:onboarding_profile).permit(
      :age,
      :sex,
      :height,
      :weight,
      :activity_level,
      :pregnancy_status,
      :lactation_status
    )
  end
end
