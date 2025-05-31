class Onboarding::PeopleController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    if update_onboarding_profile(people_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def people_params
    params.require(:onboarding_profile).permit(
      :household_size,
      :household_size_category,
      :number_of_people
    )
  end
end
