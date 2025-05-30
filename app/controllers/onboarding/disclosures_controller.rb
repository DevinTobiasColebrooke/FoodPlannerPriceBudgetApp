class Onboarding::DisclosuresController < Onboarding::BaseController
  skip_before_action :require_onboarding_profile, only: [:show, :update]

  def show
    @privacy_policy = LegalDocument.current_privacy_policy
    @terms_of_service = LegalDocument.current_terms_of_service
    @disclosure = LegalDocument.current_disclosure
  end

  def update
    if params[:acknowledged]
      update_onboarding_profile(disclosure_params)
      redirect_to new_onboarding_profile_info_path
    else
      redirect_to onboarding_disclosure_path, alert: "Please acknowledge the disclosures to continue"
    end
  end

  private

  def disclosure_params
    params.permit(:acknowledged)
  end
end
