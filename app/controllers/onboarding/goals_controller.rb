class Onboarding::GoalsController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @goals = Goal.all
  end

  def create
    update_onboarding_profile(goal_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_people_path
    else
      @goals = Goal.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def goal_params
    params.require(:onboarding_profile).permit(:main_goal, side_goals: [])
  end
end
