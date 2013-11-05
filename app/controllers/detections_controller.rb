# -*- coding: utf-8 -*-
require_relative 'search_cache'

class DetectionsController < ApplicationController
  # GET /detections
  # GET /detections.json
  def index
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

    device_area_voltage_id = params[:voltage_level]
    device_type_id = params[:device_type]
    device_area_id = params[:device_area]           # 出现[间隔单元|杆塔号]查询条件
    begin_date = params[:begin_date]
    end_date = params[:end_date]
    fault_ids = params[:fault_nature]
    items_per_page = ( params[:rows] || '40' ).to_i
    curpage = ( params[:page] || '1' ).to_i
    offset = ( curpage - 1 ) * items_per_page
    zone = params[:zone]

    conditions = "1=1"
    conditions << " AND `detections`.device_area_voltage_id = #{device_area_voltage_id}" unless device_area_voltage_id.blank?
    conditions << " AND `detections`.device_type_id = #{device_type_id}" unless device_type_id.blank?
    conditions << " AND `detections`.detect_date >= '#{begin_date}'" unless begin_date.blank?
    conditions << " AND `detections`.detect_date <= '#{end_date}'" unless end_date.blank?

    substation_ids = []
    device_type_list = []

    if level == 1
      unless zone.blank?
        region_ids = Region.select('id').find_all_by_name(zone).map(&:id)
        substation_ids = Substation.select('id').where("region_id IN (?)", region_ids).map(&:id)
        if substation_ids.empty?
          conditions << " AND `detections`.substation_id=-1"
        else
          conditions << " AND `detections`.substation_id IN(#{substation_ids.join(',')})"
        end
      end
      device_type_list = DeviceType.select('id, name').order('id ASC')
    end

    # 点击供电公司
    if level == 2
      region_ids = Region.select('id').find_all_by_parent_id(select_id).map(&:id)
      substation_ids = Substation.select('id').where("region_id IN (?)", region_ids).map(&:id)

      # c = conditions + " AND regions.id IN(#{region_ids.join(',')})"
      # p Detection.find_regoin_composite_ids(c)
    end

    # 点击[变电|配电|输电]中心
    if level == 3
      substation_ids = Substation.select('id').find_all_by_region_id(select_id).map(&:id)
    end

    # 点击电压
    if level == 4
      substation_ids = Substation.select('id').find_all_by_region_id_and_voltage_level_id(select_parent_id, select_id).map(&:id)
    end

    if level > 1 && level < 5
      if substation_ids.empty?
        conditions << " AND `detections`.substation_id=-1"
      else
        conditions << " AND `detections`.substation_id IN(#{substation_ids.join(',')})"
      end
      device_type_ids = Detection.unscoped.select('DISTINCT device_type_id').where('substation_id in (?)', substation_ids).map(&:device_type_id)
      device_type_list = DeviceType.select('id, name').order('id ASC').where('id in (?)', device_type_ids)
    end

    areas = []
    # 点击[变电站|线路]，出现[间隔单元|杆塔号]查询条件
    if level == 5
      conditions << " AND `detections`.substation_id=#{select_id}"
      conditions << " AND `detections`.device_area_id=#{device_area_id}" unless device_area_id.blank?
      areas = DeviceArea.select('id, device_area_name').find_all_by_substation_id(select_id).collect{|item| [item.id, item.device_area_name]}
      device_type_ids = Detection.unscoped.select('DISTINCT device_type_id').find_all_by_substation_id(select_id).map(&:device_type_id)
      device_type_list = DeviceType.select('id, name').order('id ASC').where('id in (?)', device_type_ids)
    end

    search = SearchCache.new
    search.level = level
    search.select_id = select_id
    search.device_area_voltage_id = device_area_voltage_id

    search.device_type_id = device_type_id.blank? ? 0 : device_type_id
    search.device_area_id = device_area_id.blank? ? 0 : device_area_id
    search.begin_date = begin_date.blank? ? '0' : begin_date
    search.end_date = end_date.blank? ? '0' : end_date
    search.fault_ids = fault_ids.blank? ? 0 : fault_ids.gsub(',', '-')

    search.page_no = curpage
    search.page_size = items_per_page
    search.order_field = params[:sidx]
    search.order_by = params[:sord]

    count_key = search.generate_count_cache_key

    fault_count_key = search.generate_fault_cache_key

    fault_counts = Detection.find_fault_counts( conditions )
    # fault_counts = Rails.cache.fetch(fault_count_key, :expires_in => 5.minutes) do
    #   Detection.get_fault_counts( conditions )
    # end

    if fault_ids.blank?
      fault_counts.each do |h|
        h.merge!(:checked => false)
      end
    else
      checked = fault_ids.split(',')
      fault_counts.each do |h|
        h.merge!(:checked => checked.include?(h[:id].to_s))
      end
    end

    conditions << " AND detections.fault_nature_id in(#{params[:fault_nature]})" unless fault_ids.blank?

    ids = Detection.find_composite_ids( conditions, offset, items_per_page ).map(&:id)

    data = ids.map do |id|
      Detection.find_and_cache_composite_by_id(id)
    end
    detections = data
    totalrecords = Detection.where(conditions).count
    # @totalrecords = Rails.cache.fetch(count_key, :expires_in => 5.minutes){ Detection.where(conditions).count }

    totalpages = totalrecords/items_per_page
    if ( totalrecords % items_per_page ) > 0
      totalpages = totalpages + 1
    end

    list_path = "config/list.yml"

    jqdata = { 'totalpages' => totalpages, 'curpage' => curpage, 'totalrecords' => totalrecords, 'fault_counts' => fault_counts, 'data' => detections, 'areas' => areas, 'user_level' => level, 'templates' => YAML.load_file(list_path), 'device_type_list' => device_type_list}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: jqdata }
    end
  end

  # GET /detections/1
  # GET /detections/1.json
  def show
    respond_to do |format|
      format.html
      format.json {
        detection = Detection.find_and_cache_composite_by_id(params[:id])
        return if detection.nil?
        current_phasic = detection.device_phasic.blank? ? '' : detection.device_phasic
        compare_ids = detection.find_phasic_compare_ids
        resource = DetectionResource.find_and_cache_by_detection_id(detection.id)
        params_json = Hash[*resource.params_json.gsub(/\[|\]|\"/, '').split(',')] unless resource.params_json.blank?
        current_device_phasics_output = [{ "id" => detection.id, "phasic" => current_phasic, "irimage" => (resource.irimage.nil?) ? "/ir-missing.jpg" : resource.irimage.url(:original), "params_json"=>params_json, "fault_nature_name" => detection.fault_nature_name, "full_time" => detection.detect_full_time }]
	same_device_phasics_output = []
        unless compare_ids.nil?
          compare_ids.each do |item|
            phasic = item.device_phasic.blank? ? '' : item.device_phasic
            resource = DetectionResource.find_and_cache_by_detection_id(item.id)
            params_json = Hash[*resource.params_json.gsub(/\[|\]|\"/, '').split(',')] unless resource.params_json.blank?
            same_device_phasics_output << { "id" => item.id, "phasic" => phasic, "irimage" => (resource.irimage.nil?) ? "/ir-missing.jpg" : resource.irimage.url(:original), "params_json"=>params_json, "fault_nature_name" => item.fault_nature_name, "full_time" => item.detect_full_time }
          end
        end
	sorted_time_data = []
	i = 0
	same_device_phasics_output.group_by{|item| item['phasic']}.each do |key, value|
	  break if (i += 1) > 2
	  sorted_time_data << value.min_by{|item| (DateTime.parse(detection.detect_full_time) - DateTime.parse(item['full_time'])).abs}
	end
	sorted_time_data += current_device_phasics_output
        sorted_time_data.sort_by!{|item| [item['phasic'].length, item['phasic']]}
        output_data = { "cur_phasic" => current_phasic, "same_device_phasics" => sorted_time_data, 'description' => detection.item_title}
        render json: output_data
      }
    end
  end

  def destroy
    id = params[:id].to_i
    begin
      Detection.destroy(id)
      render :json => {:success => true}
    rescue Exception => ex
      logger.error(ex.message)
      render :json => {:success => false}
    end
  end

  def history
    respond_to do |format|
      format.json {
        detection = Detection.find_and_cache_composite_by_id(params[:id])
        page_no = (params[:page_no] || '1').to_i
        page_size = (params[:page_size] || '2').to_i
        if page_no == 1
          limit = page_size * 2 + 1
          offset = 0
        else
          limit = page_size
          offset = page_no * page_size + 1
        end
        params_json = ''
        resource = DetectionResource.find_and_cache_by_detection_id(detection.id)
        params_json = Hash[*resource.params_json.gsub(/\[|\]|\"/, '').split(',')] unless resource.params_json.blank?
        current_device = { "full_time" => detection.detect_full_time, "irimage" => (resource.irimage.nil?) ? "/ir-missing.jpg" : resource.irimage.url(:original), "params_json"=>params_json, :phasic => detection.device_phasic, :fault_nature => detection.fault_nature.name }
        history_ids = detection.find_same_device_historiy_ids(offset, limit)
        same_device_box = []
        history_ids.each do |h|
          resource = DetectionResource.find_and_cache_by_detection_id(h.detection_id)
          params_json = Hash[*resource.params_json.gsub(/\[|\]|\"/, '').split(',')] unless resource.params_json.blank?
          same_device_box << { "full_time" => h.detect_full_time, "irimage" => (resource.irimage.nil?) ? "/ir-missing.jpg" : resource.irimage.url(:original), "params_json"=>params_json, :phasic => h.device_phasic, :fault_nature => h.fault_nature.name}
        end
        output_data = { "current_device" => current_device, "same_device_box" => same_device_box, 'description' => detection.item_title }
        render json: output_data
      }
    end
  end

  def redo_task
    RedoTaskJob.perform_async(params[:ids])
    render :json => {:success => true}
  end

  def role_tree
    user_level = current_user.level || 1
    select_id = current_user.item_id
    select_parent_id = current_user.parent_id

    root = Node.new(-1, '根目录', -1, -1)

    cache_key = "tree_#{user_level}_#{select_id}_#{select_parent_id}"

    # 临时将权限树固定为一级用户，后期用redis替换
    if user_level == 1
      tree = Rails.cache.fetch("tree_analyse", :expires_in => 5.minutes) do
        voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
        regions = Region.select('id, name, parent_id, notes')
        substations = Substation.select('id, name, region_id, voltage_level_id')
        provinces = regions.select{|item| item.parent_id == 0}
        provinces.each do |p|
          province = Node.new(p.id, p.name, p.parent_id, 1, true, true)
          root.add(province)
          companies = regions.select{|item| item.parent_id == province.id}.sort_by{|item| item.notes.to_i}
          companies.each do |c|
            company = Node.new(c.id, c.name, c.parent_id, 2, false, true)
            province.add(company)
            lines = regions.select{|item| item.parent_id == company.id}.sort_by{|item| item.name}
            lines.each do |l|
              line = Node.new(l.id, l.name, l.parent_id, 3, false, true)
              line.line_no = set_line_no(l.name)
              company.add(line)
              stations = substations.select{|item| item.region_id == line.id}
              stations.uniq{|item| item.voltage_level_id}.map(&:voltage_level_id).each do |id|
                voltage = Node.new(id, voltages[id], line.id, 4, false)
                voltage.line_no = line.line_no
                line.add(voltage)
                voltage_stations = stations.select{|item| item.voltage_level_id == id}
                voltage_stations.each do |s|
                  station = Node.new(s.id, s.name, voltage.id, 5)
                  station.line_no = line.line_no
                  voltage.add(station)
                end
              end
            end
          end
        end
        root.children
      end
    end

    if user_level == 2
      tree = Rails.cache.fetch(cache_key, :expires_in => 5.minutes) do
        voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
        c = Region.select('id, name, parent_id').find(select_id)
        company = Node.new(c.id, c.name, c.parent_id, 2, true)
        p = Region.select('id, name, parent_id').find(company.parent_id)
        province = Node.new(p.id, p.name, p.parent_id, 1, true)
        province.add(company)
        root.add(province)
        lines = Region.select('id, name, parent_id').find_all_by_parent_id(company.id)
        lines.each do |l|
          line = Node.new(l.id, l.name, l.parent_id, 3)
          line.line_no = set_line_no(l.name)
          company.add(line)
          stations = Substation.select('id, name, voltage_level_id').find_all_by_region_id(line.id)
          stations.uniq{|item| item.voltage_level_id}.map(&:voltage_level_id).each do |id|
            voltage = Node.new(id, voltages[id], line.id, 4)
            voltage.line_no = line.line_no
            line.add(voltage)
            voltage_stations = stations.select{|item| item.voltage_level_id == voltage.id}
            voltage_stations.each do |s|
              station = Node.new(s.id, s.name, voltage.id, 5)
              station.line_no = line.line_no
              voltage.add(station)
            end
          end
        end
        root.children
      end
    end

    if user_level == 3
      tree = Rails.cache.fetch(cache_key, :expires_in => 5.minutes) do
        voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
        l = Region.select('id, name, parent_id').find(select_id)
        line = Node.new(l.id, l.name, l.parent_id, 3, true)
        line.line_no = set_line_no(l.name)
        c = Region.select('id, name, parent_id').find(line.parent_id)
        company = Node.new(c.id, c.name, c.parent_id, 2, true)
        company.line_no = line.line_no
        p = Region.select('id, name, parent_id').find(company.parent_id)
        province = Node.new(p.id, p.name, p.parent_id, 1, true)
        province.line_no = line.line_no
        company.add(line)
        province.add(company)
        root.add(province)
        stations = Substation.select('id, name, voltage_level_id').find_all_by_region_id(line.id)
        stations.uniq{|item| item.voltage_level_id}.map(&:voltage_level_id).each do |id|
          voltage = Node.new(id, voltages[id], line.id, 4)
          voltage.line_no = line.line_no
          line.add(voltage)
          voltage_stations = stations.select{|item| item.voltage_level_id == voltage.id}
          voltage_stations.each do |s|
            station = Node.new(s.id, s.name, voltage.id, 5)
            station.line_no = line.line_no
            voltage.add(station)
          end
        end
        root.children
      end
    end

    if user_level == 4
      tree = Rails.cache.fetch(cache_key, :expires_in => 5.minutes) do
        voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
        v = VoltageLevel.select('id, name').find(select_id)
        voltage = Node.new(v.id, v.name, select_parent_id, 4, true)
        l = Region.select('id, name, parent_id').find(voltage.parent_id)
        line = Node.new(l.id, l.name, l.parent_id, 3, true)
        line.line_no = set_line_no(l.name)
        voltage.line_no = line.line_no
        c = Region.select('id, name, parent_id').find(line.parent_id)
        company = Node.new(c.id, c.name, c.parent_id, 2, true)
        company.line_no = line.line_no
        p = Region.select('id, name, parent_id').find(company.parent_id)
        province = Node.new(p.id, p.name, p.parent_id, 1, true)
        province.line_no = line.line_no
        line.add(voltage)
        company.add(line)
        province.add(company)
        root.add(province)
        stations = Substation.select('id, name').find_all_by_region_id_and_voltage_level_id(voltage.parent_id, voltage.id)
        stations.each do |s|
          station = Node.new(s.id, s.name, voltage.id, 5)
          station.line_no = line.line_no
          voltage.add(station)
        end
        root.children
      end
    end

    if user_level == 5
      tree = Rails.cache.fetch(cache_key, :expires_in => 5.minutes) do
        voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
        s = Substation.select('id, name, voltage_level_id, region_id').find(select_id)
        substation = Node.new(s.id, s.name, s.voltage_level_id, 5, true)
        v = VoltageLevel.select('id, name').find(substation.parent_id)
        voltage = Node.new(v.id, v.name, s.region_id, 4, true)
        l = Region.select('id, name, parent_id').find(voltage.parent_id)
        line = Node.new(l.id, l.name, l.parent_id, 3, true)
        line.line_no = set_line_no(l.name)
        voltage.line_no = line.line_no
        substation.line_no = line.line_no
        c = Region.select('id, name, parent_id').find(line.parent_id)
        company = Node.new(c.id, c.name, c.parent_id, 2, true)
        company.line_no = line.line_no
        p = Region.select('id, name, parent_id').find(company.parent_id)
        province = Node.new(p.id, p.name, p.parent_id, 1, true)
        province.line_no = line.line_no

        voltage.add(substation)
        line.add(voltage)
        company.add(line)
        province.add(company)
        root.add(province)
        root.children
      end
    end
    respond_to do |format|
      format.json{ render :json => tree}
    end
  end

  def admin_tree
    tree = Rails.cache.fetch('admin_tree_cache', :expires_in => 5.minutes) do
      root = Node.new(-1, '根目录', -1, -1)
      voltages = Hash[*VoltageLevel.select('id, name').collect{|item| [item.id, item.name]}.flatten]
      regions = Region.select('id, name, parent_id').order('notes+0 ASC')
      substations = Substation.select('id, name, region_id, voltage_level_id')
      provinces = regions.select{|item| item.parent_id == 0}
      provinces.each do |p|
        province = Node.new(p.id, p.name, p.parent_id, 1, true)
        root.add(province)
        companies = regions.select{|item| item.parent_id == province.id}
        companies.each do |c|
          company = Node.new(c.id, c.name, c.parent_id, 2)
          province.add(company)
          lines = regions.select{|item| item.parent_id == company.id}
          lines.each do |l|
            line = Node.new(l.id, l.name, l.parent_id, 3, false, true)
            line.line_no = set_line_no(l.name)
            company.add(line)
            stations = substations.select{|item| item.region_id == line.id}
            stations.uniq{|item| item.voltage_level_id}.map(&:voltage_level_id).each do |id|
              voltage = Node.new(id, voltages[id], line.id, 4)
              voltage.line_no = line.line_no
              line.add(voltage)
              voltage_stations = stations.select{|item| item.voltage_level_id = voltage.id}
              voltage_stations.each do |s|
                station = Node.new(s.id, s.name, voltage.id, 5)
                station.line_no = line.line_no
                voltage.add(station)
              end
            end
          end
        end
      end
      root.children
    end
    respond_to do |format|
      format.json{ render :json => tree}
    end
  end

  def faults_search
    name = params[:name]
    rows = ( params[:rows] || '10' ).to_i
    page = ( params[:page] || '1' ).to_i
    offset = ( page - 1 ) * rows
    fault_ids = params[:faults] || '3,4,5'

    regions = Region.select('id').find_all_by_name(name).map(&:id)
    substation_ids = Substation.select('id').where("region_id in (?)", regions).map(&:id).join(',')
    conditions = '1=1'
    conditions << " AND `detections`.substation_id IN(#{substation_ids})"
    conditions << " AND detections.fault_nature_id in(#{fault_ids})"
    sum = Detection.select('count(*) AS sum').where(conditions)[0].sum
    ids = Detection.find_composite_ids( conditions, offset, rows ).map(&:id)

    data = ids.map do |id|
      Detection.find_and_cache_composite_by_id(id)
    end
    render :json => {totalCount: sum, data: data}
  end

  class Node
    attr_accessor :id, :name, :parent_id, :lv, :line_no, :open, :isParent, :caption
    attr_accessor :children

    def initialize(id, name, parent_id, lv, open = false, isParent = false)
      @id = id
      @name = name
      @parent_id = parent_id
      @lv = lv
      @open = open
      @isParent = isParent
      @children = []
    end

    def add(node)
      children << node
      @caption = "其下共有#{children.size}项"
    end
  end

  def set_line_no(text)
    return 1 if text.start_with?('变电')
    return 2 if text.start_with?('输电')
    return 3 if text.start_with?('配电')
    3
  end

  def as_json(options = { })
    { line_no: self.line_no}
    # super((options || { }).merge({:line_no => [:line_no]}))
  end
end
