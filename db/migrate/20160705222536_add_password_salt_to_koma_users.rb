class AddPasswordSaltToKomaUsers < ActiveRecord::Migration
  def change
    add_column :koma_users, :password, :string, null: false, default: '$2a$10$IoEbIw7rK3jiPE9OiyW6lOUh6wKQcHvYmg13I76abIlCO7ln0TqRq'
    add_column :koma_users, :salt, :string, null: false, default: '$2a$10$IoEbIw7rK3jiPE9OiyW6lO'
  end
end
