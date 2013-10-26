# -*- coding: utf-8 -*-
# 一个变电站或线路下有哪些设备区
class DeviceArea < ActiveRecord::Base
  expired_active_scaffold_cache
  belongs_to :substation
  belongs_to :voltage_level
  has_many :devices

  def to_label
    substation.nil? ? ( device_area_name ) : ( substation.name + " " + device_area_name )
  end

	def self.find_and_cache_by_id(id)
    Rails.cache.fetch("device_area_id_of_#{id}") do
      DeviceArea.find(id)
    end
  end
end

