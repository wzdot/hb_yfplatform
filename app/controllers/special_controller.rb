#coding: utf-8
require 'fileutils'

class SpecialController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:import]
	skip_before_filter :authenticate_user!, :only => [:import]

	layout 'special'

	def index
		province_ids = Region.where( parent_id: 0 ).pluck( :id )
    @companies = Region.select( 'id, name' ).order( 'notes+0 ASC' ).where( parent_id: province_ids )
    @faults = FaultNature.select('id, name').order('id ASC')
    @fixes = FixMethod.select('id, name').order('id ASC')
    @cases = ExecuteCase.select('id, name').order('id ASC')
	end

	def import
		stream = params["Filedata"]
		filename = stream.original_filename
		tempfile = stream.tempfile.path.sub('/tmp/', '')
		FileUtils.mv(stream.tempfile.path, "#{Rails.configuration.uploadify_tmp_dir}/#{tempfile}")
		respond_to do |format|
			format.json{ render :json => {:filename => filename, :tempfile => tempfile}}
		end
	end

	def create
    begin
      ActiveRecord::Base.transaction do
        detection = Detection.new
        detection.detect_date = params[:detect_date]
        detection.detect_time = params[:detect_time]
        detection.device_id = params[:device_id]
        detection.part_position_id = params[:part_position_id]
        detection.fault_nature_id = params[:fault_nature_id].presence || '1'
        detection.fixed_date = params[:fixed_date]
        detection.fix_method_id = params[:fix_method_id]
        detection.execute_case_id = params[:execute_case_id]
        detection.running_voltage = params[:running_voltage]
        detection.electrical_current = params[:electrical_current]
        detection.substation_id = params[:substation_id]
        detection.device_area_id = params[:device_area_id]
        detection.device_area_voltage_id = params[:device_area_voltage_id]
        detection.device_type_id = params[:device_type_id]
        detection.model_style_id = Device.select('model_style_id').find(detection.device_id).model_style_id

        params_json = []
        params_json << ["辐射率", params[:radiance]] unless params[:radiance].blank?
        params_json << ["距离", params[:distance]] unless params[:distance].blank?
        params_json << ["环境温度", params[:temperature]] unless params[:temperature].blank?
        params_json << ["相对湿度", params[:humidity]] unless params[:humidity].blank?
        unless params['cell'].blank?
          params_json << params['cell'].collect{|key, value| [key,"#{value['Max']}"]}
        end
        ir_temp = params[:ir_temp]
        unless ir_temp.blank?
          ir_file = DetectionResource.rand_file_name + ".jpg"
          irimage_md5 = Digest::MD5.hexdigest(File.read("#{Rails.configuration.uploadify_tmp_dir}/#{ir_temp}"))
          resource = DetectionResource.new
          resource.detection = detection
          resource.irimage_file_name = ir_file
          resource.irimage_md5 = irimage_md5
          resource.params_json = params_json.flatten.to_s
          if resource.save
            substation = detection.substation
            FileUtils.mkdir_p("#{Rails.configuration.shoot_data_uploadify_dir}/#{substation.sub_directory}")
            FileUtils.mv("#{Rails.configuration.uploadify_tmp_dir}/#{ir_temp}", "#{Rails.configuration.shoot_data_uploadify_dir}/#{substation.sub_directory}/#{ir_file}")
            @status = 0
          end
        end
      end
    rescue ActiveRecord::RecordNotUnique
      @status = 1
    rescue Exception => ex
      @status = -1
    end
  end

	def edit
		id = params[:id].to_i
		detection = Detection.find_and_cache_composite_by_id(id)
		return if detection.nil?
		resource = DetectionResource.find_and_cache_by_detection_id(detection.id)
		return if resource.nil?
		@substation = Substation.find_and_cache_by_id(detection.substation_id)
		@line = Region.find_and_cache_by_id(@substation.region_id)
		@company = Region.find_and_cache_by_id(@line.parent_id)
		@substation_voltage = VoltageLevel.find_and_cache_by_id(@substation.voltage_level_id)
		@device_area =  DeviceArea.find_and_cache_by_id(detection.device_area_id) 
		@device_area_voltage = VoltageLevel.find_and_cache_by_id(@device_area.voltage_level_id)
		@device_type = DeviceType.find_and_cache_by_id(detection.device_type_id)
		@device = Device.find_and_cache_by_id(detection.device_id)
		@model_style = ModelStyle.find_and_cache_by_id(@device.model_style_id)
		@part_position = PartPosition.find_and_cache_by_id(detection.part_position_id)
	end

	def lines
		lines = Region.select( 'id, name' ).where( parent_id: params[:parent_id] )
		respond_to do |format|
      format.json { render json: lines }
    end
	end

	def substation_voltages
		ids = Substation.select( 'DISTINCT voltage_level_id' ).where( region_id: params[:region_id] ).map( &:voltage_level_id )
		voltages = VoltageLevel.select('id, name').where(id: ids)
		respond_to do |format|
      format.json { render json: voltages }
    end
	end

	def substations
		stations = Substation.select( 'id, name' ).where( region_id: params[:line_id], voltage_level_id: params[:voltage_level_id] )
		respond_to do |format|
      format.json { render json: stations }
    end
	end

	def device_area_voltages
		voltages = VoltageLevel.select('id, name')
		respond_to do |format|
			format.json { render json: voltages }
  	end
		# ids = DeviceArea.select('DISTINCT voltage_level_id').find_all_by_substation_id(params[:substation_id]).map(&:voltage_level_id)
		# voltages = VoltageLevel.select('id, name').where('id IN (?)', ids)
		# respond_to do |format|
  	#     format.json { render json: voltages }
  	# end
	end

	def device_areas
		areas = DeviceArea.select( 'id, device_area_name AS name' ).where( substation_id: params[:substation_id], voltage_level_id: params[:voltage_level_id] )
		respond_to do |format|
      format.json { render json: areas }
    end
	end

	def add_device_area
		substation_id = params[:substation_id].to_i
		voltage_level_id = params[:voltage_level_id].to_i
		device_area_name = params[:device_area_name]
		return if device_area_name.blank?
		instance = DeviceArea.where(substation_id: substation_id, voltage_level_id: voltage_level_id, device_area_name: device_area_name.strip ).first_or_create
		respond_to do |format|
      format.json { render json: instance }
    end
	end

	def device_types
		types = DeviceType.select('id, name')
		# ids = Device.select('DISTINCT model_style_id').find_all_by_device_area_id(params[:device_area_id]).map(&:model_style_id)
		# type_ids = ModelStyle.select('DISTINCT device_type_id').where('id IN (?)', ids).map(&:device_type_id)
		# types = DeviceType.select('id, name').where('id in (?)', type_ids)
		respond_to do |format|
      format.json { render json: types }
    end
	end

	def add_device_type
		device_type = params[:device_type]
		return if device_type.blank?
		instance = DeviceType.where(name: device_type, parent_id: 0).first_or_create
		respond_to do |format|
      format.json { render json: instance }
    end
	end

	def model_styles
		device_type_id = params[:device_type_id]
		device_area_id = params[:device_area_id]
		ids = Device.select('DISTINCT model_style_id').where(device_area_id: device_area_id).map(&:model_style_id)
		styles = ModelStyle.select('id, model_style AS name').where(id: ids, device_type_id: device_type_id)
		respond_to do |format|
      format.json { render json: styles }
    end
	end

	def add_model_style
		device_type_id = params[:device_type_id]
		voltage_level_id = params[:voltage_level_id]
		model_style = params[:model_style]
		styles = ModelStyle.where(device_type_id: device_type_id, voltage_level_id: voltage_level_id, model_style: model_style).first_or_create do |instance|
      instance.name = model_style
    end
		respond_to do |format|
      format.json { render json: styles }
    end
	end

	def devices
		device_area_id = params[:device_area_id]
		model_style_id = params[:model_style_id]
		devices = Device.select( 'id, local_scene_name AS name, phasic' ).where( device_area_id: device_area_id, model_style_id: model_style_id )
		respond_to do |format|
      format.json { render json: devices }
    end
	end

	def add_device
		device_area_id = params[:device_area_id]
		model_style_id = params[:model_style_id]
		name = params[:name].strip
		if data = name.match(/(.+)\((.+?)\)/)
			local_scene_name = data[1]
			phasic = data[2]
			device = Device.where( device_area_id: device_area_id, model_style_id: model_style_id, phasic: phasic, local_scene_name: local_scene_name).first_or_create
			respond_to do |format|
	      format.json { render json: device }
	    end
	  end
	end

	def part_positions
		positions = PartPosition.select('id, name').order('id ASC')
		respond_to do |format|
      format.json { render json: positions }
    end
	end

	def add_part_position
		name = params[:name].strip
		instance = PartPosition.where( name: name ).first_or_create
		respond_to do |format|
      format.json { render json: instance }
    end
	end
end
