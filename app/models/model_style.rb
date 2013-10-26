class ModelStyle < ActiveRecord::Base
  expired_active_scaffold_cache
  belongs_to :device_type
  belongs_to :voltage_level
  belongs_to :vender

  def to_label
    "#{ model_style } #{ name }"
  end

  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("model_style_id_of_#{id}") do
      ModelStyle.find(id)
    end
  end
end
