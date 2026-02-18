class UploadsController < ApplicationController
  def new
  end

  def create
    unless params[:file]
      redirect_to new_upload_path, alert: "Please select a file"
      return
    end
    
    begin
      file = params[:file]
      
      # Use FileParserService to parse the file (handles both Excel and HTML)
      parser = FileParserService.new(file.path)
      rows = parser.parse
      
      if rows.empty?
        redirect_to new_upload_path, alert: "The file appears to be empty or contains no data."
        return
      end
      
      # First row is the header
      header = rows.first
      
      # Map Excel columns to our model attributes
      column_map = {
        "Req. No" => :req_no,
        "Group" => :group,
        "Priority" => :priority,
        "Request Date" => :request_date,
        "User ID" => :user_id,
        "User Name" => :user_name,
        "User Location" => :user_location,
        "Assigned Group" => :assigned_group,
        "Handler/Approver" => :handler_approver,
        "Summary" => :summary,
        "Age" => :age,
        "Status" => :status,
        "Category" => :category_name,
        "Item Affected" => :item_affected_name,
        "Type" => :ticket_type,
        "Last Comment" => :last_comment,
        "Resolutin Desc" => :resolution_desc,
        "Change Type" => :change_type,
        "Risk Level" => :risk_level,
        "Change Date" => :change_date,
        "Modified Date" => :modified_date
      }
      
      # Find column indices
      column_indices = {}
      header.each_with_index do |col, idx|
        column_indices[column_map[col]] = idx if column_map[col]
      end
      
      success_count = 0
      error_count = 0
      
      # Process data rows (skip header row)
      rows[1..-1].each_with_index do |row, index|
        row_num = index + 2  # For error reporting (row 1 is header)
        next if row.all?(&:blank?)
        
        begin
          # Get category and item affected
          category_name = row[column_indices[:category_name]]&.to_s&.strip
          item_affected_name = row[column_indices[:item_affected_name]]&.to_s&.strip
          
          category = nil
          item_affected = nil
          
          if category_name.present?
            category = Category.find_or_create_by!(name: category_name)
          end
          
          if item_affected_name.present? && category
            item_affected = ItemAffected.find_or_create_by!(
              name: item_affected_name,
              category: category
            )
          end
          
          # Parse dates
          request_date = parse_date(row[column_indices[:request_date]])
          change_date = parse_date(row[column_indices[:change_date]])
          modified_date = parse_date(row[column_indices[:modified_date]])
          
          # Build ticket attributes
          ticket_attrs = {
            req_no: row[column_indices[:req_no]]&.to_s&.strip,
            group: row[column_indices[:group]]&.to_s&.strip,
            priority: row[column_indices[:priority]]&.to_s&.strip,
            request_date: request_date,
            user_id: row[column_indices[:user_id]]&.to_s&.strip,
            user_name: row[column_indices[:user_name]]&.to_s&.strip,
            user_location: row[column_indices[:user_location]]&.to_s&.strip,
            assigned_group: row[column_indices[:assigned_group]]&.to_s&.strip,
            handler_approver: row[column_indices[:handler_approver]]&.to_s&.strip,
            summary: row[column_indices[:summary]]&.to_s&.strip,
            age: row[column_indices[:age]]&.to_i,
            status: row[column_indices[:status]]&.to_s&.strip,
            category: category,
            item_affected: item_affected,
            ticket_type: row[column_indices[:ticket_type]]&.to_s&.strip,
            last_comment: row[column_indices[:last_comment]]&.to_s&.strip,
            resolution_desc: row[column_indices[:resolution_desc]]&.to_s&.strip,
            change_type: row[column_indices[:change_type]]&.to_s&.strip,
            risk_level: row[column_indices[:risk_level]]&.to_s&.strip,
            change_date: change_date,
            modified_date: modified_date
          }
          
          # Find or create/update ticket by req_no
          req_no = ticket_attrs[:req_no]
          if req_no.present?
            ticket = Ticket.find_or_initialize_by(req_no: req_no)
            ticket.assign_attributes(ticket_attrs)
            if ticket.save
              success_count += 1
            else
              error_count += 1
            end
          else
            error_count += 1
          end
        rescue => e
          error_count += 1
          Rails.logger.error "Error processing row #{row_num}: #{e.message}"
        end
      end
      
      redirect_to dashboard_path, notice: "Upload completed! #{success_count} tickets processed successfully. #{error_count} errors."
    rescue ArgumentError => e
      # Handle file parsing errors (HTML parsing, Excel errors, etc.)
      redirect_to new_upload_path, alert: "Error processing file: #{e.message}"
    rescue => e
      redirect_to new_upload_path, alert: "Error processing file: #{e.message}"
    end
  end
  
  private
  
  def parse_date(date_value)
    return nil if date_value.blank?
    
    if date_value.is_a?(Date)
      date_value
    elsif date_value.is_a?(Time) || date_value.is_a?(DateTime)
      date_value.to_date
    elsif date_value.is_a?(String)
      Date.parse(date_value) rescue nil
    elsif date_value.is_a?(Numeric)
      # Excel date serial number
      Date.new(1899, 12, 30) + date_value.to_i rescue nil
    else
      nil
    end
  end
end
