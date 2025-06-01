class AllowNullEmailAndUsernameOnUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :email_address, true
    change_column_null :users, :username, true
  end
end
