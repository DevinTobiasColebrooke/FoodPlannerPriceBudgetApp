class Onboarding::AvatarsController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @avatars = Avatar.all
  end

  def create
    update_onboarding_profile(avatar_params)

    if @onboarding_profile.valid?
      redirect_to onboarding_finalize_path
    else
      @avatars = Avatar.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def avatar_params
    params.require(:onboarding_profile).permit(
      :avatar_url,
      :selected_avatar_identifier
    )
  end
end
