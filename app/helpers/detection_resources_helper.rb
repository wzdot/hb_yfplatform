module DetectionResourcesHelper
  def detection_resource_irimage_column r
    raw "<a target='blank' href='#{ r.irimage( :original ) }'> <image src='#{ r.irimage( :original ) }' /> </a>"
  end

  def detection_resource_viimage_column r
    raw "<a target='blank' href='#{ r.viimage( :original ) }'> <image src='#{ r.viimage( :original ) }' /> </a>"
  end

  def detection_resource_irp_column r
    raw "<a target='blank' href='#{ r.irp( :original ) }'> <image src='#{ r.irp( :original ) }' /> </a>"
  end

end
