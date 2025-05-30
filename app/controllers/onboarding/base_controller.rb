class Onboarding::BaseController < ApplicationController
  skip_before_action :require_authentication
  layout "onboarding"
  before_action :require_onboarding_profile

  private

  def onboarding_profile
    @onboarding_profile ||= OnboardingProfile.new(session[:onboarding_profile] || {})
  end

  def update_onboarding_profile(params)
    profile_data = onboarding_profile.attributes.merge(params)
    session[:onboarding_profile] = profile_data
    @onboarding_profile = OnboardingProfile.new(profile_data)
  end

  def require_onboarding_profile
    unless session[:onboarding_profile].present?
      redirect_to onboarding_welcome_path, alert: "Please start the onboarding process"
    end
  end
end
