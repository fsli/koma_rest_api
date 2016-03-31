class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :device_token, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end
  end
end
