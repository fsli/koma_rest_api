class CreateKomaLabels < ActiveRecord::Migration
  def change
    create_table :koma_labels do |t|
      t.integer :company_id, null: false
      t.integer :label_order, null: false
      t.string :label_text
      t.timestamps null: false
    end
    add_index :koma_labels, [:company_id, :label_order], :unique => true
  end
end
