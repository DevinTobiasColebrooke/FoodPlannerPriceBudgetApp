class AllowNullProfileFieldsForGuestUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :age_in_months, true
    change_column_null :users, :sex, true
    change_column_null :users, :height_cm, true
    change_column_null :users, :weight_kg, true
    change_column_null :users, :physical_activity_level, true
  end
end
