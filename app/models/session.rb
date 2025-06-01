class Session < ApplicationRecord
  belongs_to :user, class_name: 'UserManagement::User'
end
