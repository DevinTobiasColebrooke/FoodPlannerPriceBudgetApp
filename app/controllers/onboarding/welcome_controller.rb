class Onboarding::WelcomeController < Onboarding::BaseController
  skip_before_action :require_onboarding_profile, only: [:show, :start]

  def show
    # Reset onboarding profile when starting fresh
    session[:onboarding_profile] = {}
  end

  def start
    redirect_to next_step
  end
end
