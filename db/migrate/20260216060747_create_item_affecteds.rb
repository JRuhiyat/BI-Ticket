class CreateItemAffecteds < ActiveRecord::Migration[7.1]
  def change
    create_table :item_affecteds do |t|
      t.string :name
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
