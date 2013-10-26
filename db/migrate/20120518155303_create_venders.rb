class CreateVenders < ActiveRecord::Migration
  def change
    create_table :venders do |t|
      t.string :name, :null => false
      t.string :tel

      t.timestamps
    end

    add_index :venders, :name, :unique => true
  end
end
