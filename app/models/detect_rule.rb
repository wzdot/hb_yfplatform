class DetectRule < ActiveRecord::Base
  belongs_to :outline
  belongs_to :fault_nature
  attr_accessible :rule_formula, :rule_text, :fault_nature_id, :order_num, :outline_id, :rule_title
end
