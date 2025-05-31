class Onboarding::BaseController < ApplicationController
  skip_before_action :require_authentication
  layout "onboarding"
  before_action :require_onboarding_profile

  private

  def onboarding_profile
    @onboarding_profile ||= begin
      raw_session_data = session[:onboarding_profile] || {}
      # Symbolize keys and remove the problematic 'allergies_input' key
      cleaned_session_data = raw_session_data.deep_symbolize_keys
      cleaned_session_data.delete(:allergies_input)
      OnboardingProfile.new(cleaned_session_data)
    end
  end

  def update_onboarding_profile(params)
    profile_data = onboarding_profile.attributes.merge(params)
    session[:onboarding_profile] = profile_data
    @onboarding_profile = OnboardingProfile.new(profile_data)
  rescue StandardError => e
    Rails.logger.error("Failed to update onboarding profile: #{e.message}")
    @onboarding_profile.errors.add(:base, "Failed to save your progress. Please try again.")
    false
  end

  def require_onboarding_profile
    unless session[:onboarding_profile].present?
      redirect_to onboarding_welcome_path, alert: "Please start the onboarding process"
    end
  end

  # Navigation methods
  def next_step
    current_step = self.class.name.demodulize.underscore.gsub('_controller', '').singularize
    current_index = ONBOARDING_STEPS.index(current_step)
    next_step_name = ONBOARDING_STEPS[current_index + 1]

    return onboarding_finalize_path if next_step_name.nil? # Finalize might be special

    # Check if the route is for a :new action or :show based on routes.rb
    # For simplicity, assuming steps like 'goal', 'people', 'allergy', etc. are 'new' actions for now.
    # More robust check would inspect Rails.application.routes directly or use a convention.
    if %w[goal person allergy equipment time_prep shopping avatar finalize].include?(next_step_name)
      send("new_onboarding_#{next_step_name}_path")
    else
      # Assuming steps like 'welcome', 'disclosure', 'profile_info' map to 'show' actions (or similar direct resource path)
      send("onboarding_#{next_step_name}_path")
    end
  end

  def previous_step
    current_step = self.class.name.demodulize.underscore.gsub('_controller', '').singularize
    prev_step = ONBOARDING_STEPS[ONBOARDING_STEPS.index(current_step) - 1]
    return onboarding_welcome_path if prev_step.nil?
    send("onboarding_#{prev_step}_path")
  end

  # Define the order of onboarding steps
  ONBOARDING_STEPS = %w[
    welcome
    disclosure
    profile_info
    goal
    person
    allergy
    equipment
    time_prep
    shopping
    avatar
  ].freeze
end
