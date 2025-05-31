class Onboarding::DisclosuresController < Onboarding::BaseController
  skip_before_action :require_onboarding_profile, only: [:show, :update]

  def show
    @profile = onboarding_profile
    @privacy_policy = LegalDocument.current_privacy_policy
    @terms_of_service = LegalDocument.current_terms_of_service
  end

  def update
    if update_onboarding_profile(disclosure_params)
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

  def disclosure_params
    params.require(:onboarding_profile).permit(:acknowledged)
  end
end
