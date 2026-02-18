class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :req_no
      t.string :group
      t.string :priority
      t.date :request_date
      t.string :user_id
      t.string :user_name
      t.string :user_location
      t.string :assigned_group
      t.string :handler_approver
      t.text :summary
      t.integer :age
      t.string :status
      t.references :category, null: true, foreign_key: true
      t.references :item_affected, null: true, foreign_key: true
      t.string :ticket_type
      t.text :last_comment
      t.text :resolution_desc
      t.string :change_type
      t.string :risk_level
      t.date :change_date
      t.date :modified_date

      t.timestamps
    end
    
    add_index :tickets, :req_no, unique: true
  end
end
