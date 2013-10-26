class CreateDetectRules < ActiveRecord::Migration
  def change
    create_table :detect_rules do |t|
      t.references :outline, :null => false
      t.references :fault_nature, :null => false
      t.integer    :order_num, :null => false
      t.string     :rule_title, :null => false
      t.text       :rule_text
      t.text       :rule_formula

      t.timestamps
    end

    add_index :detect_rules, :outline_id
    add_index :detect_rules, :fault_nature_id
    add_index :detect_rules, [ :outline_id, :fault_nature_id, :order_num ], :unique => true, :name => "unique_index"
  end
end
