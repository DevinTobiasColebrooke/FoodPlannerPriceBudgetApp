class Onboarding::AllergiesController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @common_allergies = UserManagement::Allergy.common
  end

  def create
    if update_onboarding_profile(allergy_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      @common_allergies = UserManagement::Allergy.common
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def allergy_params
    params.require(:onboarding_profile).permit(
      :allergies,
      :allergies_input,
      common_allergies: [],
      allergy_severities: {},
      allergy_notes: {}
    )
  end
end
