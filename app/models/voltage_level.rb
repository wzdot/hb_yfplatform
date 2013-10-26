class VoltageLevel < ActiveRecord::Base
	# has_many :device_areas
	expired_active_scaffold_cache

	def self.find_and_cache_by_id(id)
    Rails.cache.fetch("voltage_level_id_of_#{id}") do
      VoltageLevel.find(id)
    end
  end
end
