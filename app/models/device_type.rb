class DeviceType < ActiveRecord::Base
	expired_active_scaffold_cache
  belongs_to :parent, :class_name => "DeviceType"

  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("device_type_id_of_#{id}") do
      DeviceType.find(id)
    end
  end
end
