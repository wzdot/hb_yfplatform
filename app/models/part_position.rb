class PartPosition < ActiveRecord::Base
	expired_active_scaffold_cache

	def self.find_and_cache_by_id(id)
    Rails.cache.fetch("part_position_id_of_#{id}") do
      PartPosition.find(id)
    end
  end
end
