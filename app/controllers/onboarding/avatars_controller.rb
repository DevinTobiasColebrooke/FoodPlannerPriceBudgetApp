class Onboarding::AvatarsController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @avatars = Avatar.all
  end

  def create
    if update_onboarding_profile(avatar_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      @avatars = Avatar.all
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def avatar_params
    params.require(:onboarding_profile).permit(
      :avatar_url,
      :selected_avatar_identifier
    )
  end
end
