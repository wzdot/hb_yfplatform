module DeviceShootSequencesHelper
  def device_shoot_sequence_substation_column r
    r.shoot_sequence.substation.name
  end

  def device_shoot_sequence_device_area_column r
    r.device_area.device_area_name if r.device_area
  end

  def device_column r
    "#{ r.device.model_style.device_type.name } #{ r.device.model_style.model_style } #{ r.device.model_style.name } #{ r.device.phasic }"
  end

end
