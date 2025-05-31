class Onboarding::FinalizeController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    profile = onboarding_profile
    user = current_user

    user.assign_attributes(
      age: profile.age,
      sex: profile.sex,
      height: profile.height,
      weight: profile.weight,
      activity_level: profile.activity_level,
      is_pregnant: profile.pregnancy_status,
      is_lactating: profile.lactation_status,
      lactation_period: profile.lactation_period,
      household_size_category: profile.household_size_category,
      number_of_people: profile.number_of_people,
      preferred_prep_time_max_minutes: profile.preferred_prep_time_max_minutes,
      preferred_cook_time_max_minutes: profile.preferred_cook_time_max_minutes,
      meal_difficulty_preference: profile.meal_difficulty_preference,
      shopping_difficulty_preference: profile.shopping_difficulty_preference,
      weekly_budget_amount: profile.weekly_budget_amount,
      budget_is_flexible: profile.budget_is_flexible,
      location_preference_type: profile.location_preference_type,
      zip_code: profile.zip_code,
      avatar_url: profile.avatar_url,
      selected_avatar_identifier: profile.selected_avatar_identifier,
      onboarding_completed_at: Time.current
    )

    # Create associated records
    if profile.main_goal.present?
      goal = Goal.find_by(name: profile.main_goal)
      user.user_goals.create(goal: goal, is_primary: true) if goal
    end

    profile.side_goals&.each do |side_goal_name|
      goal = Goal.find_by(name: side_goal_name)
      user.user_goals.create(goal: goal, is_primary: false) if goal
    end

    profile.allergies&.each do |allergy_name|
      allergy = Allergy.find_by(name: allergy_name)
      if allergy
        user.user_allergies.create(
          allergy: allergy,
          severity: profile.allergy_severities[allergy_name],
          notes: profile.allergy_notes[allergy_name]
        )
      end
    end

    profile.equipment&.each do |equipment_name|
      equipment = Equipment.find_by(name: equipment_name)
      user.user_equipment.create(equipment: equipment) if equipment
    end

    if user.save
      session.delete(:onboarding_profile)
      redirect_to authenticated_root_path, notice: "Welcome! Your profile is set up."
    else
      redirect_to new_onboarding_avatar_path, alert: "Could not save profile. Please review your entries."
    end
  end
end
