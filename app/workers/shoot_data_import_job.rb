#coding: utf-8
require 'fileutils'

class ShootDataImportJob
	include Sidekiq::Worker
	include IrDetect
	sidekiq_options queue: "shoot_data", :retry => false

	RULE = {
		'__0' => '-',
		'__1' => '~',
		'__2' => '`',
		'__3' => '!',
		'__4' => '@',
		'__5' => '#',
		'__6' => '$',
		'__7' => '%',
		'__8' => '^',
		'__9' => '&',
		'__a' => '*',
		'__b' => '(',
		'__c' => ')',
		'__d' => '+',
		'__e' => '=',
		'__f' => '{',
		'__g' => '}',
		'__h' => '[',
		'__i' => ']',
		'__j' => '|',
		'__k' => '\\',
		'__l' => ':',
		'__m' => ';',
		'__n' => '"',
		'__o' => '\'',
		'__p' => '<',
		'__q' => '>',
		'__r' => ',',
		'__s' => '.',
		'__t' => '?',
		'__u' => '/',
	}

	def perform(filename, src)
		if data = /^(\d)(\d{4})(\d{4})(\d{6})-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)\.(jpg|irp|irp\.jpg)$/.match(filename)
			resolution = Resolution.new
			resolution.version = data[1]
			resolution.year = data[2]
			resolution.month_day = data[3]
			resolution.hour_minute_second = data[4]
			# resolution.substation_voltage = replace_special_chars(format_voltage_level(data[5]))
			resolution.substation_voltage = replace_special_chars(data[5])
			resolution.substation = replace_special_chars(data[6])
			# resolution.device_area_voltage = replace_special_chars(format_voltage_level(data[7]))
			resolution.device_area_voltage = replace_special_chars(data[7])
			resolution.device_area = replace_special_chars(data[8])
			# resolution.device_voltage = replace_special_chars(format_voltage_level(data[9]))
			resolution.device_voltage = replace_special_chars(data[9])
			resolution.local_scene_name = replace_special_chars(data[10])
			resolution.device_type = replace_special_chars(data[11])
			resolution.model_style = replace_special_chars(data[12])
			resolution.phasic = replace_special_chars(data[13])
			resolution.part_position = replace_special_chars(data[14])
			resolution.extension = data[15]
			handler = Handler.new
			substation_voltage = handler.execute(2, :name => resolution.substation_voltage)
			substation = handler.execute(3, :name => resolution.substation, :voltage_level_id => substation_voltage.id)
			device_area_voltage = handler.execute(2, :name => resolution.device_area_voltage)
			device_area = handler.execute(4, :substation_id => substation.id, :voltage_level_id => device_area_voltage.id, :device_area_name => resolution.device_area)
			device_voltage = handler.execute(2, :name => resolution.device_voltage)
			device_type = handler.execute(6, :name => resolution.device_type, :parent_id => 0)
			model_style = handler.execute(7, :device_type_id => device_type.id, :voltage_level_id => device_voltage.id, :model_style => resolution.model_style)
			device = handler.execute(5, :device_area_id => device_area.id, :model_style_id => model_style.id, :phasic => resolution.phasic)
			part_position = handler.execute(8, :name => resolution.part_position)
=begin
缺陷等级：危急=5，严重=4，一般=3，关注=2，正常=1，未知=99
	无规则:
		fault_nature_id=100，rule_id=-1
	有规则：
		诊断出错：
			fault_nature_id=100，出错的rule_id
		诊断不匹配：
			fault_nature_id=1，rule_id=0(区别正常匹配时fault_nature_id=1，相应的rule_id)
		诊断匹配
			相应的fault_nature_id和rule_id
=end
			fault_nature_id = 100
			detect_rule_id = -1
			
			params_json = ""

			FileUtils.mkdir_p("#{Rails.configuration.shoot_data_uploadify_dir}/#{substation.sub_directory}")
			FileUtils.mkdir_p("#{Rails.configuration.shoot_data_uploadify_irp_dir}/#{substation.sub_directory}")

			md5_filename = DetectionResource.md5_file_name(filename)

			if resolution.extension == 'jpg'
				dst = "#{Rails.configuration.shoot_data_uploadify_dir}/#{substation.sub_directory}/#{md5_filename}"
				FileUtils.mv(src, dst)
				begin
					Detection.transaction do
						detection = Detection.find_or_create_by_detect_date_and_detect_time_and_part_position_id_and_device_id(:detect_date => resolution.date, :detect_time => resolution.time, :device_id => device.id, :part_position_id => part_position.id, :substation_id => substation.id, :device_area_id => device_area.id, :device_area_voltage_id => device_area_voltage.id, :device_type_id =>device_type.id, :model_style_id => model_style.id, :fault_nature_id => fault_nature_id, :detect_rule_id => detect_rule_id)
						if detection
							irimage_md5 = Digest::MD5.hexdigest(File.read(dst))
							DetectionResource.find_or_create_by_detection_id(:detection_id => detection.id, :irimage_file_name => filename, :irimage_md5 => irimage_md5, :params_json => params_json)
						end
					end
				rescue Exception => ex
					logger.error ex
				end
			end

			if resolution.extension == 'irp.jpg' || resolution.extension == 'irp'
				dst = "#{Rails.configuration.shoot_data_uploadify_irp_dir}/#{substation.sub_directory}/#{md5_filename}"
				FileUtils.mv(src, dst)
				
				irimage_file_name = "#{filename[0..-9]}.jpg" if resolution.extension == 'irp.jpg'
				irimage_file_name = "#{filename[0..-5]}.jpg" if resolution.extension == 'irp'
				md5_irimage_file_name = DetectionResource.md5_file_name(irimage_file_name)
				irimage_file_path = "#{Rails.configuration.shoot_data_uploadify_dir}/#{substation.sub_directory}/#{md5_irimage_file_name}"
				outline = Outline.select('id, ana_unit_text').find_by_model_style_id_and_part_position_id(model_style.id, part_position.id)
				outline_id = 0
				if outline.nil? || outline.ana_unit_text.blank?
					parse_irp_unit = `convert-irp-to-jpg "#{dst}" "#{irimage_file_path}"`
				else
					parse_irp_unit = `convert-irp-to-jpg "#{dst}" "#{irimage_file_path}" "#{outline.ana_unit_text}"`
					outline_id = outline.id
				end
				
				params_json, fault_nature_id, detect_rule_id = detect_irp(parse_irp_unit.chomp, outline_id)

				begin
					Detection.transaction do
						detection = Detection.find_or_create_by_detect_date_and_detect_time_and_part_position_id_and_device_id(:detect_date => resolution.date, :detect_time => resolution.time, :device_id => device.id, :part_position_id => part_position.id, :substation_id => substation.id, :device_area_id => device_area.id, :device_area_voltage_id => device_area_voltage.id, :device_type_id =>device_type.id, :model_style_id => model_style.id, :fault_nature_id => fault_nature_id, :detect_rule_id => detect_rule_id)
						if detection
							irp_md5 = Digest::MD5.hexdigest(File.read(dst)) 
							irimage_md5 = Digest::MD5.hexdigest(File.read(irimage_file_path))
							map = {:detection_id => detection.id, :irp_file_name => filename, :irimage_file_name => irimage_file_name, :irimage_md5 => irimage_md5, :irp_md5 => irp_md5}
							map.merge!(:params_json => params_json) unless params_json.blank?
							resource = DetectionResource.find_by_detection_id(detection.id)
							if resource.nil?
								DetectionResource.create(map)
							else
								resource.update_attributes(map)
								resource.delete_cache
							end
						end
					end
				rescue Exception => ex
					logger.error ex
				end
			end
		end
	end

	def replace_special_chars(text)
		text.scan(/(__\d|__[a-u])/).flatten.each do |char|
			text.sub!(char, RULE[char])
		end
		text
	end

	def format_voltage_level(voltage_level)
		if data = voltage_level.match(/(\+-)?(\d+\.\d+)|(\+-)?(\d+)/)
			return "#{data[0]}kV"
		end
		voltage_level
	end

	class Resolution
		attr_accessor :version							# 版本号
		attr_accessor :year 								# 年份
		attr_accessor :month_day						# 月日
		attr_accessor :hour_minute_second		# 时间
		attr_accessor :substation_voltage		# 变电站电压等级
		attr_accessor :substation						# 变电站名
		attr_accessor :device_area_voltage	# 设备区电压等级
		attr_accessor :device_area					# 设备区名
		attr_accessor :device_voltage				# 设备电压等级
		attr_accessor :local_scene_name			# 设备备注
		attr_accessor	:device_type					# 设备类型
		attr_accessor :model_style					# 设备型号
		attr_accessor :phasic								# 相别
		attr_accessor :part_position				# 部位角度
		attr_accessor :extension						# 扩展名

		def date
			month = month_day[0, 2]
			day = month_day[2, 2]
			"#{year}-#{month}-#{day}"
		end

		def time
			hour = hour_minute_second[0, 2]
			minute = hour_minute_second[2, 2]
			second = hour_minute_second[4, 2]
			"#{hour}:#{minute}:#{second}"
		end
	end

	class Handler
		@@options = [
			{:table => 'Detection', :sql => 'find_by_device_id_and_part_position_id_and_detect_date_and_detect_time'},
			{:table => 'DetectionResource', :sql => 'find_by_detection_id'},
			{:table => 'VoltageLevel', :sql => 'find_by_name'},
			{:table => 'Substation', :sql => 'find_by_name_and_voltage_level_id'},
			{:table => 'DeviceArea', :sql => 'find_by_substation_id_and_voltage_level_id_and_device_area_name'},
			{:table => 'Device', :sql => 'find_by_device_area_id_and_model_style_id_and_phasic'},
			{:table => 'DeviceType', :sql => 'find_by_name_and_parent_id'},
			{:table => 'ModelStyle', :sql => 'find_by_device_type_id_and_voltage_level_id_and_model_style'},
			{:table => 'PartPosition', :sql => 'find_by_name'},
		]

		def execute(id, hash = {})
			option = @@options[id]
			option[:table].constantize.send(:find, :first, :conditions => hash)
			# key = option[:table].downcase
			# hash.each do |item, value|
			# 	key << "_#{item}_#{value}"
			# end
			# key = Digest::MD5.hexdigest(key)
			# instance = Rails.cache.fetch(key, :expires_in => 5.minutes) do
			# 	option[:table].constantize.send(:find, :first, :conditions => hash)
			# end
		end

		def self.flush_all
			Detection.delete_all
			DetectionResource.delete_all
			FileUtils.rm_rf(Dir.glob("#{Rails.configuration.shoot_data_uploadify_dir}/*"))
			FileUtils.rm_rf(Dir.glob("#{Rails.configuration.shoot_data_uploadify_irp_dir}/*"))
		end
	end
end
