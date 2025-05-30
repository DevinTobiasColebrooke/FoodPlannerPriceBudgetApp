class Onboarding::EquipmentController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @equipment = Equipment.all
  end

  def create
    update_onboarding_profile(equipment_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_time_prep_path
    else
      @equipment = Equipment.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def equipment_params
    params.require(:onboarding_profile).permit(equipment: [])
  end
end
