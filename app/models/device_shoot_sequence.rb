class DeviceShootSequence < ActiveRecord::Base
  belongs_to :shoot_sequence
  belongs_to :device_area
  belongs_to :device

  # default_scope :order => 'shoot_sequence_id, device_area_id, order_num ASC'
  default_scope :order => 'order_num'


  def selected_part_position
  	PartPositionShootSequence.select('shoot_sequence_id, device_area_id, device_id, part_position_id').where( "shoot_sequence_id = #{ self.shoot_sequence_id } AND device_area_id = #{ self.device_area_id } AND device_id = #{ self.device_id }" )
  end
end
