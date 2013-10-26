#coding: utf-8
module IrDetect
	# parse_irp_unit 数据格式
	# radiance=0.89;distance=5;temperature=23.0;humidity=70;R01[Max]=10;R01[Min]=1;R01[Avg]=3;R02[Max]=30;R02[Min]=10;R02[Avg]=20;
	def detect_irp(parse_irp_unit, outline_id)
		fault_nature_id = 100
		detect_rule_id = -1
		params_json = generate_params_json(parse_irp_unit)
		rules = DetectRule.select('id, fault_nature_id, rule_formula').order('fault_nature_id DESC, order_num ASC').find_all_by_outline_id(outline_id)
		if outline_id == 0 || rules.empty?
			params_json = generate_params_json(parse_irp_unit)
		else
			params_json = generate_params_json(parse_irp_unit)

			data_to_hash = Hash[*parse_irp_unit.split(';').collect{|item| item.split('=')}.flatten]
			ana_unit_hash = data_to_hash.select{|key, value| key =~ /[A-Z]\d{2}\[\w{3}\]/}
			
			rules.each do |rule|
				formula = rule.rule_formula
				ana_unit_hash.each do |key, value|
					formula.gsub!(key, value)
				end
				formula.gsub!('AND', '&&')
				formula.gsub!('OR', '||')
				begin
					if eval(formula)
						fault_nature_id = rule.fault_nature_id
						detect_rule_id = rule.id
						break
					else
						fault_nature_id = 1
						detect_rule_id = 0
					end
				rescue
					fault_nature_id = 100
					detect_rule_id = rule.id
				end
			end
		end
		[params_json, fault_nature_id, detect_rule_id]
	end

	def generate_params_json(parse_irp_unit)
		data_to_hash = Hash[*parse_irp_unit.split(';').collect{|item| item.split('=')}.flatten]
		ana_unit_hash = data_to_hash.select{|key, value| key =~ /[A-Z]\d{2}\[\w{3}\]/}
		ana_unit_hash_max = data_to_hash.select{|key, value| key =~ /[A-Z]\d{2}\[Max\]/}
		# params_json = parse_irp_unit.gsub('radiance', '辐射率').gsub('distance', '距离').gsub('temperature', '环境温度').gsub('humidity', '相对湿度').gsub(/\[(Max|Min|Avg)\]/, '').split(';').collect{|item| item.split('=')}.flatten.to_s unless parse_irp_unit.blank?
		json = []
		json << ['辐射率', data_to_hash['radiance']]
		json << ['距离', data_to_hash['distance']]
		json << ['环境温度', data_to_hash['temperature']]
		json << ['相对湿度', data_to_hash['humidity']]
		ana_unit_hash_max.each do |key, value|
			json << [key.gsub(/\[Max\]/, ''), value]
		end
		params_json = json.flatten.to_s
	end
end