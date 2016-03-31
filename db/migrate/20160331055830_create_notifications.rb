class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id, null: false
      t.text  :message, null: false
      t.integer :badge, null: false 
      t.boolean :is_pushed, null: false, default: false
      t.timestamps null: false
    end
  end
end
