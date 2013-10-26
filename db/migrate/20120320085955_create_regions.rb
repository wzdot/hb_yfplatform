class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name, :null => false
      t.string :notes
      t.references :parent

      t.timestamps
    end

    add_index :regions, :name
    add_index :regions, :parent_id
    add_index :regions, [ :parent_id, :name ], :name => "unique_index", :unique => true
  end
end
