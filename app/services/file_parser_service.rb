require 'roo'
require 'roo-xls'
require 'nokogiri'

class FileParserService
  attr_reader :file_path, :file_type

  def initialize(file_path)
    @file_path = file_path
    @file_type = detect_file_type
  end

  def parse
    case file_type
    when :html
      parse_html
    when :xlsx, :xls
      parse_excel
    else
      raise ArgumentError, "Unsupported file type: #{file_type}"
    end
  end

  private

  def detect_file_type
    # Read first ~200 bytes to detect file type
    File.open(file_path, 'rb') do |f|
      header = f.read(200)
      return :unknown if header.nil? || header.empty?
      
      # Check for HTML indicators
      header_str = header.force_encoding('UTF-8')
      if header_str.match?(/\A\s*(<!DOCTYPE|<html|<table)/i)
        return :html
      end
      
      # XLSX files start with PK (ZIP signature)
      if header[0..1] == "PK"
        return :xlsx
      end
      
      # XLS files (OLE2) start with specific bytes
      # OLE2 files start with: D0 CF 11 E0 A1 B1 1A E1
      if header.length >= 8 && header[0..7].unpack('C*') == [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1]
        return :xls
      end
    end
    
    :unknown
  rescue => e
    Rails.logger.error "Error detecting file type: #{e.message}"
    :unknown
  end

  def parse_html
    html_content = File.read(file_path)
    doc = Nokogiri::HTML(html_content)
    
    # Find the first table
    table = doc.at_css('table')
    unless table
      raise ArgumentError, "No table found in HTML file"
    end
    
    rows = []
    table.css('tr').each do |tr|
      row = []
      tr.css('td, th').each do |cell|
        # Get text content, strip whitespace
        cell_text = cell.text.strip
        row << cell_text
      end
      rows << row unless row.all?(&:blank?)
    end
    
    rows
  rescue => e
    Rails.logger.error "Error parsing HTML: #{e.message}"
    raise ArgumentError, "Failed to parse HTML file: #{e.message}"
  end

  def parse_excel
    spreadsheet = nil
    error_messages = []
    
    # Try to open based on detected type first
    types_to_try = [file_type]
    
    # If file_type is :xlsx or :xls, also try the other as fallback
    if file_type == :xlsx
      types_to_try << :xls
    elsif file_type == :xls
      types_to_try << :xlsx
    end
    
    types_to_try.each do |type|
      begin
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: type)
        Rails.logger.info "Successfully opened file as #{type}"
        break
      rescue => e
        error_messages << "#{type}: #{e.message}"
        Rails.logger.error "Error reading as #{type}: #{e.message}"
        next
      end
    end
    
    unless spreadsheet
      detailed_error = error_messages.join("; ")
      Rails.logger.error "Failed to open file. Errors: #{detailed_error}"
      raise ArgumentError, "Could not read the Excel file. Please ensure it's a valid .xlsx or .xls file. Error details: #{error_messages.first}"
    end
    
    # Convert spreadsheet rows to array format
    rows = []
    (1..spreadsheet.last_row).each do |row_num|
      row = spreadsheet.row(row_num)
      rows << row unless row.all?(&:blank?)
    end
    
    rows
  end
end

