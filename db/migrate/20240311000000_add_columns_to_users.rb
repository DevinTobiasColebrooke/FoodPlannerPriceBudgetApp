class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, limit: 255, null: false
    add_column :users, :avatar_url, :string, limit: 255
    add_column :users, :household_size, :string, limit: 50
    add_column :users, :cooking_time_preference, :string, limit: 50
    add_column :users, :meal_difficulty_preference, :string, limit: 50
    add_column :users, :shopping_difficulty_preference, :string, limit: 50
    add_column :users, :weekly_budget, :decimal, precision: 10, scale: 2
    add_column :users, :flexible_budget, :boolean, default: true, null: false
    add_column :users, :location_preference_type, :string, limit: 50
    add_column :users, :zip_code, :string, limit: 20
    add_column :users, :age_in_months, :integer, null: false
    add_column :users, :sex, :string, limit: 20, null: false
    add_column :users, :height_cm, :decimal, precision: 5, scale: 1, null: false
    add_column :users, :weight_kg, :decimal, precision: 5, scale: 2, null: false
    add_column :users, :physical_activity_level, :string, limit: 50, null: false
    add_column :users, :is_pregnant, :boolean, null: false, default: false
    add_column :users, :pregnancy_trimester, :integer
    add_column :users, :is_lactating, :boolean, null: false, default: false
    add_column :users, :lactation_period, :string, limit: 20
    add_column :users, :is_smoker, :boolean, null: false, default: false
    add_column :users, :is_vegetarian_or_vegan, :boolean, null: false, default: false
    add_column :users, :onboarding_completed_at, :timestamp

    add_index :users, :username, unique: true
  end
end
