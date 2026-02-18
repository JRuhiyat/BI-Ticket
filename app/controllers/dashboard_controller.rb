class DashboardController < ApplicationController
  def index
    @category_filter = params[:category_id]
    @item_affected_filter = params[:item_affected_id]
    @period_filter = params[:period] || "month"
    @sort_order = params[:sort_order] || "desc"
    
    @tickets = Ticket.all
    
    # Apply filters
    if @category_filter.present?
      @tickets = @tickets.where(category_id: @category_filter)
    end
    
    if @item_affected_filter.present?
      @tickets = @tickets.where(item_affected_id: @item_affected_filter)
    end
    
    # Total tickets
    @total_tickets = @tickets.count
    @completed_tickets = @tickets.where("LOWER(status) = ?", "completed").count
    @not_completed_tickets = @total_tickets - @completed_tickets
    
    # Tickets by category
    @tickets_by_category = @tickets.group(:category_id)
      .joins(:category)
      .group("categories.name")
      .count
    
    @completed_by_category = @tickets.where("LOWER(status) = ?", "completed")
      .group(:category_id)
      .joins(:category)
      .group("categories.name")
      .count
    
    @not_completed_by_category = {}
    @tickets_by_category.each do |key, total|
      completed = @completed_by_category[key] || 0
      @not_completed_by_category[key] = total - completed
    end
    
    # Status distribution
    @status_distribution = @tickets.group(:status).count
    
    # Category and Item Affected distribution
    @category_distribution = @tickets.joins(:category)
      .group("categories.name")
      .count
    
    @item_affected_distribution = @tickets.joins(:item_affected)
      .group("item_affecteds.name")
      .count
    
    # Top 10 User Locations
    @user_locations = @tickets.where.not(user_location: [nil, ""])
      .group(:user_location)
      .count
      .sort_by { |k, v| @sort_order == "asc" ? v : -v }
      .first(10)
      .to_h
    
    # Time series data
    @time_series = {}
    @completed_time_series = {}
    
    if @tickets.any?
      case @period_filter
      when "day"
        @time_series = @tickets.group_by_day(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_day(:request_date).count
      when "month"
        @time_series = @tickets.group_by_month(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_month(:request_date).count
      when "year"
        @time_series = @tickets.group_by_year(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_year(:request_date).count
      end
    end
    
    @categories = Category.all.order(:name)
    @item_affecteds = @category_filter.present? ? 
      ItemAffected.where(category_id: @category_filter).order(:name) : 
      ItemAffected.all.order(:name)
  end
end
