#coding: utf-8

class RedoTaskJob
	include Sidekiq::Worker
	sidekiq_options queue: "detect_redo", :retry => false

	def perform(ids)
		if ids == 0
			Detection.select('model_style_id, part_position_id').find_each(:batch_size => 1000) do |detection|
				outline = Outline.select('ana_unit_text').find_by_model_style_id_and_part_position_id(detection.model_style_id, detection.part_position_id)
				if outline
					resource = DetectionResource.select('irimage_file_name').find_by_detection_id(detection.id)
					if resource
						params_json, fault_nature_id, detect_rule_id = detect_irp(irimage_file_name, outline)
						begin
							Detection.transaction do
								detection.update_attribute(:fault_nature_id => fault_nature_id, :detect_rule_id => detect_rule_id)
								resource.update_attribute(:params_json => params_json)
							end
						rescue Exception => ex
							logger.error ex
						end
					end
				end
	    end
	  end
	end
end