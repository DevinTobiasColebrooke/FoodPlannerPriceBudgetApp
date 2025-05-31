class Onboarding::EquipmentController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @equipment_options = UserManagement::KitchenEquipment.all
  end

  def create
    if update_onboarding_profile(equipment_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      @equipment_options = UserManagement::KitchenEquipment.all
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def equipment_params
    params.require(:onboarding_profile).permit(equipment: [])
  end
end
