module DeviceAreaShootSequencesHelper
  def device_area_shoot_sequence_device_shoot_sequences_column r
    t "app.detail"
  end

  def device_area_shoot_sequence_substation_column r
    r.shoot_sequence.substation.name
  end

  def device_area_shoot_sequence_device_area_column r
    r.device_area.device_area_name
  end
end
