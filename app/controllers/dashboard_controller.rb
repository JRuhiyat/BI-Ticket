class DashboardController < ApplicationController
  def index
    @category_filter = Array.wrap(params[:category_id]).map(&:presence).compact
    @item_affected_filter = params[:item_affected_id]
    @period_filter = params[:period].presence || "month"
    @sort_order = params[:sort_order] || "desc"

    @start_date, @end_date = parse_date_range(
      params[:start_date],
      params[:end_date]
    )

    @tickets = Ticket.all

    # Apply filters
    if @category_filter.present?
      @tickets = @tickets.where(category_id: @category_filter)
    end

    if @item_affected_filter.present?
      @tickets = @tickets.where(item_affected_id: @item_affected_filter)
    end

    @tickets = @tickets.where(request_date: @start_date..@end_date)

    @filter_params = dashboard_filter_params
    
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

    # Aged distribution (buckets) applied to filtered @tickets using the age field
    age_buckets = {
      "0-7 days" => 0,
      "8-14 days" => 0,
      "15-30 days" => 0,
      "31-60 days" => 0,
      "61+ days" => 0,
      "Unknown" => 0
    }

    # Count by bucket using age field; tickets without age -> Unknown
    @tickets.where.not(age: nil).pluck(:age).each do |age_value|
      days = age_value.to_i
      case days
      when 0..7 then age_buckets["0-7 days"] += 1
      when 8..14 then age_buckets["8-14 days"] += 1
      when 15..30 then age_buckets["15-30 days"] += 1
      when 31..60 then age_buckets["31-60 days"] += 1
      else age_buckets["61+ days"] += 1
      end
    end

    nil_count = @tickets.where(age: nil).count
    age_buckets["Unknown"] = nil_count if nil_count.positive?

    @age_distribution = age_buckets.reject { |_k, v| v == 0 }
    
    # Top 10 User Locations
    @user_locations = @tickets.where.not(user_location: [nil, ""])
      .group(:user_location)
      .count
      .sort_by { |k, v| @sort_order == "asc" ? v : -v }
      .first(10)
      .to_h
    
    # Time series data
    @completed_time_series = {}
    @not_completed_time_series = {}
    
    if @tickets.any?
      case @period_filter
      when "day"
        total_time_series = @tickets.group_by_day(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_day(:request_date).count
        all_keys = (total_time_series.keys | @completed_time_series.keys).sort
        all_keys.each do |key|
          total = total_time_series[key] || 0
          completed = @completed_time_series[key] || 0
          @not_completed_time_series[key] = total - completed
        end
      when "month"
        total_time_series = @tickets.group_by_month(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_month(:request_date).count
        all_keys = (total_time_series.keys | @completed_time_series.keys).sort
        all_keys.each do |key|
          total = total_time_series[key] || 0
          completed = @completed_time_series[key] || 0
          @not_completed_time_series[key] = total - completed
        end
      when "year"
        total_time_series = @tickets.group_by_year(:request_date).count
        @completed_time_series = @tickets.where("LOWER(status) = ?", "completed").group_by_year(:request_date).count
        all_keys = (total_time_series.keys | @completed_time_series.keys).sort
        all_keys.each do |key|
          total = total_time_series[key] || 0
          completed = @completed_time_series[key] || 0
          @not_completed_time_series[key] = total - completed
        end
      end
    end

    # Simple pagination without kaminari if needed
    if defined?(Kaminari)
      @tickets = @tickets.page(params[:page] || 1).per(50)
    else
      page = (params[:page] || 1).to_i
      per_page = 50
      @tickets = @tickets.limit(per_page).offset((page - 1) * per_page)
    end
    
    @categories = Category.all.order(:name)
    @item_affecteds = if @category_filter.present?
                        ItemAffected.where(category_id: @category_filter).order(:name)
                      else
                        ItemAffected.all.order(:name)
                      end
  end

  private

  def parse_date_range(start_param, end_param)
    start_d = parse_dashboard_date(start_param) || 12.months.ago.to_date
    end_d = parse_dashboard_date(end_param) || Time.zone.today
    start_d, end_d = end_d, start_d if start_d > end_d
    [start_d, end_d]
  end

  def parse_dashboard_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def dashboard_filter_params
    {
      category_id: @category_filter.presence,
      item_affected_id: @item_affected_filter.presence,
      start_date: @start_date.to_s,
      end_date: @end_date.to_s,
      period: @period_filter,
      sort_order: @sort_order
    }.compact
  end
end
