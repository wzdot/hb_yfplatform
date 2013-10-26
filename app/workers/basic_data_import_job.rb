#coding: utf-8

class BasicDataImportJob
	include Sidekiq::Worker
	sidekiq_options queue: "basic_data", :retry => false

	def perform(filename, associate)
		relations = {}
		associate.each{|item| a = item.split(':'); relations[a[0].to_i] = a[1].to_i}
		dst = "#{Rails.configuration.uploadify_tmp_dir}/#{filename}"
		suffix = filename.end_with?('xls') ? 'xls' : 'xlsx'
		if suffix == 'xls'
			s = Roo::Excel.new(dst)
		else
			s = Roo::Excelx.new(dst)
		end
		s.default_sheet = s.sheets.first
		rows = s.last_row
		handler = Handler.new
		progress_id = filename[0, 32]
		record_count = rows - 1
		refresh_unit = 20
		count = 0
		2.upto(rows) do |i|
			begin
				# 省级电力公司
				index = 0
				text = s.cell(i, relations[index])
				province = handler.execute(index, :name => text, :parent_id => 0)

				# 市级电力公司
				index = 1
				text = s.cell(i, relations[index])
				city = handler.execute(index, :name => text, :parent_id => province.id)

				# 工区
				index = 2
				text = s.cell(i, relations[index])
				text_name = '配电'
				text_name = '变电' if text.index('变电')
				text_name = '输电' if text.index('输电')
				zone = handler.execute(index, :name => text_name, :parent_id => city.id)

				# 部位角度
				index = 14
				text = s.cell(i, relations[index])
				position = handler.execute(index, :name => text)

				# 电站电压
				index = 3
				text = s.cell(i, relations[index])
				voltage = handler.execute(index, :name => text)

				# 变电站
				index = 4
				text = s.cell(i, relations[index])
				substation = handler.execute(index, :name => text, :region_id => zone.id, :voltage_level_id => voltage.id)

				# 生产厂商
				index = 12
				text = s.cell(i, relations[index])
				vender = handler.execute(index, :name => text.blank? ? '' : text)

				# 设备类型
				index = 5
				text = s.cell(i, relations[index])
				device_type = handler.execute(index, :name => text, :parent_id => 0)

				# 设备电压
				index = 10
				text = s.cell(i, relations[index])
				text = text.blank? ? '' : text
				voltage = handler.execute(index, :name => text)

				# 设备型号(model_style) 设备名称(name)
				index = 11
				text = s.cell(i, relations[index])
				name = s.cell(i, relations[6])
				model_style = handler.execute(index, :device_type_id => device_type.id, :voltage_level_id => voltage.id, :model_style => text, :name => name)


				# 电压等级
				index = 7
				text = s.cell(i, relations[index])
				voltage = handler.execute(index, :name => text)

				# 间隔单元
				index = 8
				text = s.cell(i, relations[index])
				device_area = handler.execute(index, :substation_id => substation.id, :voltage_level_id => voltage.id, :device_area_name => text)

				# 相别 设备现场名称资料
				index = 9
				text = s.cell(i, relations[index])
				text = text.blank? ? '' : text
				name = s.cell(i, relations[13])
				device = handler.execute(index, :device_area_id => device_area.id, :model_style_id => model_style.id, :phasic => text, :local_scene_name => name, :vender_id => vender.id)
			ensure
				count = count + 1
				if count % refresh_unit == 0 || count == record_count
					Rails.cache.write(progress_id, (count * 100 / record_count))
				end
			end
		end
	end


	class Handler
		attr_reader :cache

		@@options = [
			{:name => '省级电力公司', :table => 'Region', :sql => 'find_or_initialize_by_name_and_parent_id'},
			{:name => '市级电力公司', :table => 'Region', :sql => 'find_or_initialize_by_name_and_parent_id'},
			{:name => '工区', :table => 'Region', :sql => 'find_or_initialize_by_name_and_parent_id'},
			{:name => '电站电压', :table => 'VoltageLevel', :sql => 'find_or_initialize_by_name'},
			{:name => '变电站', :table => 'Substation', :sql => 'find_or_initialize_by_name_and_region_id'},
			{:name => '设备类型', :table => 'DeviceType', :sql => 'find_or_initialize_by_name_and_parent_id'},
			{:name => '设备名称', :table => 'ModelStyle', :sql => 'find_or_initialize_by_device_type_id_and_voltage_level_id_and_model_style'},
			{:name => '设备区电压', :table => 'VoltageLevel', :sql => 'find_or_initialize_by_name'},
			{:name => '间隔单元', :table => 'DeviceArea', :sql => 'find_or_initialize_by_substation_id_and_voltage_level_id_and_device_area_name'},
			{:name => '相别', :table => 'Device', :sql => 'find_or_initialize_by_device_area_id_and_model_style_id_and_phasic'},
			{:name => '设备电压', :table => 'VoltageLevel', :sql => 'find_or_initialize_by_name'},
			{:name => '设备型号', :table => 'ModelStyle', :sql => 'find_or_initialize_by_device_type_id_and_voltage_level_id_and_model_style'},
			{:name => '生产厂家', :table => 'Vender', :sql => 'find_or_initialize_by_name'},
			{:name => '设备现场名称资料', :table => 'Device', :sql => 'find_or_initialize_by_device_area_id_and_model_style_id_and_phasic'},
			{:name => '部位角度', :table => 'PartPosition', :sql => 'find_or_initialize_by_name'}
		]

		def initialize
			@cache = Hash.new
		end

		def execute(index, hash = {})
			option = @@options[index]
			key = option[:table].downcase
			fields = option[:sql].gsub('find_or_initialize_by_', '').split('_and_')
			fields.each do |field|
				key << "_#{hash[field.intern]}"
			end

			instance = cache[key]
			unless instance
				instance = option[:table].constantize.send(option[:sql], hash)
				instance.skip_expire_fragment = true
				instance.save
				cache[key] = instance
			end
			instance
		end

		def self.fixed_columns
			@@options.map{|item| item[:name]}
		end

		def self.flush_all
			Rails.cache.delete('tree_analyse')
			Region.delete_all
			Vender.delete_all
			PartPosition.delete_all
			VoltageLevel.delete_all
			Substation.delete_all
			DeviceType.delete_all
			ModelStyle.delete_all
			DeviceArea.delete_all
			Device.delete_all
		end
	end
end