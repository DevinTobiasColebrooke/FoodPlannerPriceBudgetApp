class Onboarding::FinalizeController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    # Load profile from session first
    profile_from_session = onboarding_profile

    # Merge data from request parameters (e.g., from the avatar step if it submits here)
    # This ensures data from the very last step is included.
    # The `onboarding_profile` key in params should match how other steps submit their data.
    if params[:onboarding_profile].present?
      # Create a new OnboardingProfile instance from merged attributes
      # to ensure all attributes are properly handled by the form object.
      merged_attributes = profile_from_session.attributes.deep_merge(params[:onboarding_profile].to_unsafe_h.deep_symbolize_keys)
      profile = OnboardingProfile.new(merged_attributes)
    else
      profile = profile_from_session
    end

    if profile.respond_to?(:email) && profile.email.present?
      user = UserManagement::User.find_or_initialize_by(email: profile.email)
      # If it's a new user (found by email but not yet in DB, or initialized), set the name.
      if user.new_record? && profile.respond_to?(:name) && profile.name.present?
        user.name = profile.name
      end
    else
      # No email provided, create a guest user
      # This assumes your User model can handle guest: true and associated validations (e.g., email not required for guests)
      user = UserManagement::User.new(guest: true)
      if profile.respond_to?(:name) && profile.name.present?
        user.name = profile.name
      end
    end

    # Password needs to be handled according to your app's authentication strategy
    # For new users (email or guest), password setting might be deferred or handled by Devise/other gems.

    user_attributes = {
      sex: profile.sex,
      is_pregnant: (profile.pregnancy_status == 'true' || profile.pregnancy_status == true),
      is_lactating: (profile.lactation_status == 'true' || profile.lactation_status == true),
      lactation_period: profile.lactation_period,
      # Preferences that are directly on the User model
      meal_difficulty_preference: profile.meal_difficulty_preference,
      shopping_difficulty_preference: profile.shopping_difficulty_preference,
      location_preference_type: profile.location_preference_type,
      onboarding_completed_at: Time.current
    }

    # Convert age from years to months if profile.age is present
    user_attributes[:age_in_months] = profile.age.to_i * 12 if profile.respond_to?(:age) && profile.age.present?

    # Map height, weight, and activity_level if present
    user_attributes[:height_cm] = profile.height if profile.respond_to?(:height) && profile.height.present?
    user_attributes[:weight_kg] = profile.weight if profile.respond_to?(:weight) && profile.weight.present?
    user_attributes[:physical_activity_level] = profile.activity_level if profile.respond_to?(:activity_level) && profile.activity_level.present?

    # Assign avatar_url and selected_avatar_identifier if they exist on User model and profile
    user_attributes[:avatar_url] = profile.avatar_url if profile.respond_to?(:avatar_url) && profile.avatar_url.present? && user.respond_to?(:avatar_url=)
    user_attributes[:selected_avatar_identifier] = profile.selected_avatar_identifier if profile.respond_to?(:selected_avatar_identifier) && profile.selected_avatar_identifier.present? && user.respond_to?(:selected_avatar_identifier=)

    user.assign_attributes(user_attributes)

    # Attributes NOT directly on User model (remove or handle separately):
    # household_size_category: profile.household_size_category,
    # number_of_people: profile.number_of_people,
    # preferred_prep_time_max_minutes: profile.preferred_prep_time_max_minutes,
    # preferred_cook_time_max_minutes: profile.preferred_cook_time_max_minutes,
    # weekly_budget_amount: profile.weekly_budget_amount,
    # budget_is_flexible: profile.budget_is_flexible,
    # zip_code: profile.zip_code,

    # Create associated records
    if profile.main_goal.present?
      goal = UserManagement::Goal.find_by(name: profile.main_goal)
      user.user_goals.create(goal: goal, is_primary: true) if goal
    end

    profile.side_goals&.each do |side_goal_name|
      goal = UserManagement::Goal.find_by(name: side_goal_name)
      user.user_goals.create(goal: goal, is_primary: false) if goal
    end

    profile.allergies&.each do |allergy_name|
      allergy = UserManagement::Allergy.find_by(name: allergy_name)
      if allergy
        user.user_allergies.create(
          allergy: allergy,
          severity: profile.allergy_severities[allergy_name],
          notes: profile.allergy_notes[allergy_name]
        )
      end
    end

    profile.equipment&.each do |equipment_name|
      equipment = UserManagement::Equipment.find_by(name: equipment_name)
      user.user_equipment.create(equipment: equipment) if equipment
    end

    if user.save
      session.delete(:onboarding_profile)
      # Start a session for the user so they are logged in after onboarding
      start_new_session_for(user)
      redirect_to authenticated_root_path, notice: "Welcome! Your profile is set up."
    else
      # Log the validation errors to help diagnose the issue
      Rails.logger.error "Failed to save user during onboarding finalization. Errors: #{user.errors.full_messages.join(', ')}"
      Rails.logger.error "Onboarding profile data at time of failure: #{profile.attributes.inspect}"
      redirect_to new_onboarding_avatar_path, alert: "Could not save profile. Please review your entries. Errors: #{user.errors.full_messages.join(', ')}"
    end
  end
end
