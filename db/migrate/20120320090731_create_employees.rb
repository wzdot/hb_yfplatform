class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :email, :null => false
      t.string :name, :null => false
      t.string :mobile
      t.string :tel
      t.references :region

      t.timestamps
    end
    
    add_index :employees, :email, :unique => true
    add_index :employees, :name
    add_index :employees, :region_id
  end
end
