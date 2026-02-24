class Ticket < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :item_affected, optional: true
  
  validates :req_no, presence: true, uniqueness: true
  
  def timeline_days
    return 0 unless request_date && modified_date
    age.to_i
  end
  
  def timeline_display
    return "N/A" unless request_date && modified_date
    days = timeline_days
    if days < 30
      "#{days} days"
    elsif days < 365
      "#{(days / 30.0).round(1)} months"
    else
      "#{(days / 365.0).round(1)} years"
    end
  end
  
  def completed?
    status&.downcase == "completed"
  end
end
