class Substation < ActiveRecord::Base
	expired_active_scaffold_cache
  belongs_to :voltage_level
  belongs_to :region

  has_many   :shoot_sequences
  # has_many   :device_areas

  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("substation_id_of_#{id}") do
      Substation.find(id)
    end
  end

  def sub_directory
    "#{id}-#{name}"
  end
end
