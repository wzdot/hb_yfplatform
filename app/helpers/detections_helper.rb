module DetectionsHelper
  def detection_detect_time_column r
    r.detect_time.strftime("%H:%M")  #to_formatted_s(:long)
  end

  def detection_detection_resources_column r
    t "app.show"
  end
end
