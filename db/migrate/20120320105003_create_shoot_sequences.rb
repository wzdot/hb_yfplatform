class CreateShootSequences < ActiveRecord::Migration
  def change
    create_table :shoot_sequences do |t|
      t.references :substation, :null => false
      t.string :name, :null => false
      t.text :notes

      t.timestamps
    end

    add_index :shoot_sequences, :substation_id
    add_index :shoot_sequences, :name
    add_index :shoot_sequences, [ :substation_id, :name ], :name => "unique_index", :unique => true
  end
end
