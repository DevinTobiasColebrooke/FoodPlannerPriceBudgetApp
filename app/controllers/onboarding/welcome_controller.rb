class Onboarding::WelcomeController < Onboarding::BaseController
  skip_before_action :require_onboarding_profile, only: [:show]

  def show
    # Reset onboarding profile when starting fresh
    session[:onboarding_profile] = {}
  end
end
