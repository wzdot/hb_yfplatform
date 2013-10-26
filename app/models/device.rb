
class Device < ActiveRecord::Base
  expired_active_scaffold_cache
  belongs_to :device_area
  belongs_to :model_style
  # has_many :detections

  def to_label
    ( device_area ? device_area.to_label : "" ) + ( model_style ? model_style.to_label : "" )
  end

  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("device_id_of_#{id}") do
      Device.find(id)
    end
  end
end
