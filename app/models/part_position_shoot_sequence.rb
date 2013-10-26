class PartPositionShootSequence < ActiveRecord::Base
  belongs_to :shoot_sequence
  belongs_to :device_area
  belongs_to :device
  belongs_to :part_position
end
