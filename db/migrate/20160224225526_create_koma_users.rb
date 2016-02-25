class CreateKomaUsers < ActiveRecord::Migration
  def change
    create_table :koma_users do |t|
      t.string :username
      t.integer :attr

      t.timestamps null: false
    end
  end
end
