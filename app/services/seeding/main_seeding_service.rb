module Seeding
  class MainSeedingService
    def self.call
      new.call
    end

    def call
      puts "Starting seeding process..."
      destroy_existing_data

      # Phase 1: Simple Lookup Table Seeding
      Seeding::SimpleLookupSeedingService.call

      # Phase 2: Foundational Data from CSVs
      Seeding::FoundationalDataSeedingService.call

      # Phase 3: Dependent DRI & EER Data
      Seeding::DriEerDataSeedingService.call

      puts "--------------------------------"
      puts "Seeding completed successfully!"
    end

    private

    def destroy_existing_data
      puts "Destroying existing data..."

      # User-related data
      UserManagement::UserGoal.destroy_all
      UserManagement::UserAllergy.destroy_all
      UserManagement::UserDietaryRestriction.destroy_all
      UserManagement::UserKitchenEquipment.destroy_all
      Shopping::ShoppingListItem.destroy_all
      MealPlanning::MealPlanEntry.destroy_all
      MealPlanning::RecipeNutritionItem.destroy_all
      MealPlanning::RecipeIngredient.destroy_all

      # Nutrition-related data
      Nutrition::DietaryPatternFoodGroupRecommendation.destroy_all
      Nutrition::DietaryPatternCalorieLevel.destroy_all
      Nutrition::DriValue.destroy_all
      Nutrition::GrowthFactor.destroy_all
      Nutrition::PalDefinition.destroy_all
      Nutrition::ReferenceAnthropometry.destroy_all
      Nutrition::EerAdditiveComponent.destroy_all
      Nutrition::EerProfile.destroy_all

      # Shopping and meal planning data
      Shopping::ShoppingList.destroy_all
      MealPlanning::Recipe.destroy_all
      MealPlanning::Ingredient.destroy_all
      Shopping::Store.destroy_all
      UserManagement::Session.destroy_all
      UserManagement::User.destroy_all

      # Simple lookup tables
      UserManagement::Goal.destroy_all
      UserManagement::Allergy.destroy_all
      UserManagement::DietaryRestriction.destroy_all
      UserManagement::KitchenEquipment.destroy_all

      # Critical: Nutrient must be destroyed before tables that reference it
      Nutrition::Nutrient.destroy_all

      # Food groups and dietary patterns
      Nutrition::FoodGroup.where.not(parent_food_group_id: nil).destroy_all
      Nutrition::FoodGroup.where(parent_food_group_id: nil).destroy_all
      Nutrition::DietaryPattern.destroy_all
      Nutrition::LifeStageGroup.destroy_all

      puts "All specified existing data destroyed."
      puts "--------------------------------"
    end
  end
end
