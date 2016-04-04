class AddBadgeNumberToKomaUser < ActiveRecord::Migration
  def change
    add_column :koma_users, :badge_number, :integer, null: false, default: 0
  end
end
