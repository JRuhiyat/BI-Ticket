class Category < ApplicationRecord
  has_many :item_affecteds, dependent: :destroy
  has_many :tickets, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
end
