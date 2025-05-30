class Onboarding::AllergiesController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @allergies = Allergy.all
  end

  def create
    update_onboarding_profile(allergy_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_equipment_path
    else
      @allergies = Allergy.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def allergy_params
    params.require(:onboarding_profile).permit(
      allergies: [],
      allergy_severities: {},
      allergy_notes: {}
    )
  end
end
