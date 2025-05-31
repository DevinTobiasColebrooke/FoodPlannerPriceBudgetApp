class Onboarding::GoalsController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
    @goals = ::UserManagement::Goal.all
  end

  def create
    if update_onboarding_profile(goal_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      @goals = ::UserManagement::Goal.all
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def goal_params
    params.require(:onboarding_profile).permit(:main_goal, side_goals: [])
  end
end
