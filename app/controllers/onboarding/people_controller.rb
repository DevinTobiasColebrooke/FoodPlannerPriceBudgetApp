class Onboarding::PeopleController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    update_onboarding_profile(people_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_allergy_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def people_params
    params.require(:onboarding_profile).permit(
      :household_size_category,
      :number_of_people
    )
  end
end
