class AddUniqueToDeviceToken < ActiveRecord::Migration
  def change
      add_index :devices, [:device_token], unique: true
  end
end
