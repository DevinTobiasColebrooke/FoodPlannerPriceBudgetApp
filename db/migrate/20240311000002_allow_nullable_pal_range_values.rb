class AllowNullablePalRangeValues < ActiveRecord::Migration[7.1]
  def change
    change_column_null :pal_definitions, :pal_range_min_value, true
    change_column_null :pal_definitions, :pal_range_max_value, true
  end
end
