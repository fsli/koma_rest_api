class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :company_name, null: false
      t.integer :account_status, null: false, default: 0
      t.string :admin_email
      t.string :admin_pass
      t.string :company_url
      t.timestamps null: false
    end
  end
end
