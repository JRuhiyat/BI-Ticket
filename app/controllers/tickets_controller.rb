class TicketsController < ApplicationController
  def index
    @category_filter = params[:category_id]
    @item_affected_filter = params[:item_affected_id]
    @search = params[:search]
    
    @tickets = Ticket.includes(:category, :item_affected).all
    
    # Apply filters
    if @category_filter.present?
      @tickets = @tickets.where(category_id: @category_filter)
    end
    
    if @item_affected_filter.present?
      @tickets = @tickets.where(item_affected_id: @item_affected_filter)
    end
    
    # Apply search
    if @search.present?
      @tickets = @tickets.where(
        "req_no ILIKE ? OR user_name ILIKE ? OR summary ILIKE ? OR status ILIKE ?",
        "%#{@search}%", "%#{@search}%", "%#{@search}%", "%#{@search}%"
      )
    end
    
    @tickets = @tickets.order(created_at: :desc)
    
    # Simple pagination without kaminari if needed
    if defined?(Kaminari)
      @tickets = @tickets.page(params[:page] || 1).per(50)
    else
      page = (params[:page] || 1).to_i
      per_page = 50
      @tickets = @tickets.limit(per_page).offset((page - 1) * per_page)
    end
    
    @categories = Category.all.order(:name)
    @item_affecteds = @category_filter.present? ? 
      ItemAffected.where(category_id: @category_filter).order(:name) : 
      ItemAffected.all.order(:name)
  end

  def show
    @ticket = Ticket.find(params[:id])
  end
end
