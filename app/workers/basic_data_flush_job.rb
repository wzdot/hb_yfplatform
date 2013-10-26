class BasicDataFlushJob
	include Sidekiq::Worker
	sidekiq_options queue: "basic_data", :retry => false

	def perform(progress_id)
		Rails.cache.delete('tree_analyse')
		Rails.cache.delete(progress_id)
		base = ActionController::Base.new
		['regions', 'voltage_levels', 'substations', 'device_types', 'model_styles', 'device_areas', 'devices', 'venders', 'part_positions'].each do |ctrl_name|
			base.expire_fragment /active_scaffold_fragment_#{ctrl_name}_.*/
		end
	end
end