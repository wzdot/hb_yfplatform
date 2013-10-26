# -*- coding: utf-8 -*-
class DeviceAreaShootSequence < ActiveRecord::Base
  belongs_to :shoot_sequence
  belongs_to :device_area

  default_scope :order => 'order_num'

  def device_shoot_sequences
    DeviceShootSequence.where( "shoot_sequence_id = #{ self.shoot_sequence_id } AND device_area_id = #{ self.device_area_id }" )
  end


  def selected_device
  	DeviceShootSequence.select('shoot_sequence_id, device_area_id, device_id').where("shoot_sequence_id = #{self.shoot_sequence_id} AND device_area_id = #{self.device_area_id}" )
  end
end
