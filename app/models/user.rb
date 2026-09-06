class User < ApplicationRecord
  # has_secure_password (auth bypassed for offline desktop mode)
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
