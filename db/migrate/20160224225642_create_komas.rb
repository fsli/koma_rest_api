class CreateKomas < ActiveRecord::Migration
  def change
    create_table :komas do |t|
      t.integer :owner_id
      t.datetime :koma_date
      t.integer :koma_type
      t.string :prospect_name
      t.text :memo

      t.timestamps null: false
    end
  end
end
