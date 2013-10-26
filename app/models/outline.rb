class Outline < ActiveRecord::Base
  belongs_to :model_style
  belongs_to :part_position
  attr_accessible :ana_unit_text, :outline_text, :model_style_id, :part_position_id
end
