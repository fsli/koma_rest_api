class AddKomaUserInfoToKomaUsers < ActiveRecord::Migration
  def change
    add_column :koma_users, :company_id, :integer, null: true
    add_column :koma_users, :nickname, :string, null: true
    add_column :koma_users, :picture_url, :string, null: true
    add_column :koma_users, :facebook_id, :string, null: true
  end
end
