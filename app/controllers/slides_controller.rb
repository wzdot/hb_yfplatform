class Slide
  attr_accessor :big, :description, :image, :thumb, :title
end

class SlidesController < ApplicationController
	layout 'slide'

	def irp_slider
    return unless params[:format]

    user_level = current_user.level
    level = params[:level].to_i
    if level < user_level
      level = user_level
      select_id = current_user.item_id
      select_parent_id = current_user.parent_id
    else
      select_id = params[:select_id].to_i
      select_parent_id = params[:select_parent_id].to_i
    end


    items_per_page = ( params[:page_size] || '40' ).to_i
    curpage = ( params[:page_no] || '1' ).to_i
    offset = ( curpage - 1 ) * items_per_page

    device_type_id = params[:device_type]
    device_area_voltage_id = params[:voltage_level] # 隐藏"设备区电压等级"筛选条件
    device_area_id = params[:device_area]           # 出现[间隔单元|杆塔号]查询条件
    begin_date = params[:begin_date]
    end_date = params[:end_date]
    fault_ids = params[:fault_nature]
    zone = params[:zone]

    conditions = "1=1"
    conditions << " AND `detections`.device_type_id=#{device_type_id}" unless device_type_id.blank?
    conditions << " AND `detections`.device_area_voltage_id=#{device_area_voltage_id}" unless device_area_voltage_id.blank?
    conditions << " AND `detections`.detect_date >= '#{begin_date}'" unless begin_date.blank?
    conditions << " AND `detections`.detect_date <= '#{end_date}'" unless end_date.blank?
    conditions << " AND detections.fault_nature_id in(#{params[:fault_nature]})" unless fault_ids.blank?

    unless zone.blank?
      region_ids = Region.select('id').find_all_by_name(zone).map(&:id)
      substation_ids = Substation.select('id').where("region_id IN (?)", region_ids).map(&:id).join(',')
      if substation_ids.empty?
        conditions << " AND `detections`.substation_id=0"
      else
        conditions << " AND `detections`.substation_id IN(#{substation_ids})"
      end
    end

    # 点击供电公司
    if level == 2
      region_ids = Region.select('id').find_all_by_parent_id(select_id).map(&:id)
      substation_ids = Substation.select('id').where("region_id IN (?)", region_ids).map(&:id).join(',')
      conditions << " AND `detections`.substation_id IN(#{substation_ids})"
    end

    # 点击[变电|配电|输电]中心
    if level == 3
      substation_ids = Substation.select('id').find_all_by_region_id(select_id).map(&:id).join(',')
      conditions << " AND `detections`.substation_id IN(#{substation_ids})"
    end

    # 点击电压
    if level == 4
      substation_ids = Substation.select('id').find_all_by_region_id_and_voltage_level_id(select_parent_id, select_id).map(&:id).join(',')
      conditions << " AND `detections`.substation_id IN(#{substation_ids})"
    end

    # 点击[变电站|线路]，出现[间隔单元|杆塔号]查询条件
    if level == 5
      conditions << " AND `detections`.substation_id=#{select_id}"
      conditions << " AND `detections`.device_area_id=#{device_area_id}" unless device_area_id.blank?
    end

    ids = Detection.find_composite_ids( conditions, offset, items_per_page ).map(&:id)

    detections = ids.map do |id|
      Detection.find_and_cache_composite_by_id(id)
    end

  	array = []
  	detections.each do |detection|
  		instance = Slide.new
      resource = DetectionResource.find_and_cache_by_detection_id(detection.id)
  		irimage = resource.irimage
      file = irimage.url
      if irimage.path.nil? || !File.exists?(irimage.path)
        file = DetectionResource.default_missing_url
      end
  		instance.image = file
  		instance.thumb = file
  		instance.big = file
  		instance.title = ''
  		instance.description = detection.detect_description
  		array << instance
  	end
  	respond_to do |format|
      format.json {render :json => array}
      format.html
		end
	end
end


