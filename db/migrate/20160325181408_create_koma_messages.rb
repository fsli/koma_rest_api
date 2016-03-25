class CreateKomaMessages < ActiveRecord::Migration
  def change
    create_table :koma_messages do |t|
#      KOMA_MESSAGE
#      id INT (autogenrated)
#      user_id INT  Required
#      Company_id INT Required
#      Message Text or String  (up to 1000 chars) CAN BE NULL
#      URL String  CAN BE NULL
#      OKO INT set to 0 when entry is created unelss specified
#      ATTR INT set to 0 when etntry is created unless cpecified
#      Read_BY INT set to 0 when entry is created      
      t.integer :user_id , null: false
      t.integer :company_id, null: false
      t.text :content, limit: 1000, null: true
      t.text :url, limit: 2083, null: true  #max url length is 2083
      t.integer :oko, null: false, default: 0
      t.integer :attr, null: false, default: 0
      t.integer :read_by, null: false, default: 0 
      t.timestamps null: false
    end
  end
end
