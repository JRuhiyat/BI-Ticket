class ItemAffected < ApplicationRecord
  belongs_to :category
  has_many :tickets, dependent: :destroy
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id }
end
