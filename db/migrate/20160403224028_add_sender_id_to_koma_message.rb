class AddSenderIdToKomaMessage < ActiveRecord::Migration
  def change
      add_column :koma_messages, :sender_user_id, :integer, null: false, default: 0
    end
end
