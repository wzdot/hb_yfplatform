module DevicesHelper
  def device_device_area_column r
    r.device_area.device_area_name if r.device_area
  end

  def device_device_type_column r
    r.model_style.device_type.name if r.model_style && r.model_style.device_type
  end

  def device_device_name_column r
    r.model_style.name if r.model_style
  end

  def device_model_style_column r
    r.model_style.model_style if r.model_style
  end

  def device_area_form_column(record, input_name)
    options = DeviceArea.select('id, device_area_name').collect do |c|
      [ c.device_area_name, c.id ]
    end
    select :record, :device_area_id, options, {:include_blank => false, :prefix => input_name}
  end

  def model_style_form_column(record, input_name)
    options = ModelStyle.select('id, model_style').collect{|c| [ c.model_style, c.id ]}
    select :record, :model_style_id, options, {:include_blank => false, :prefix => input_name}
  end
end
