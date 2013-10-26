# -*- coding: utf-8 -*-
class Detection < ActiveRecord::Base
  belongs_to :device
  belongs_to :part_position
  belongs_to :fault_nature
  belongs_to :fault_degree
  belongs_to :execute_case
  belongs_to :fix_method
  belongs_to :substation

  has_one :detection_resource, :dependent => :destroy

  default_scope :order => "detections.id DESC"

  attr_accessor :company

  def to_label
    device.to_label + " " + detect_date.to_s + " " + detect_time.strftime( "%H:%M" )
  end

  def as_json(options = { })
    super((options || { }).merge({:methods => [:company]}))
  end

  def self.find_fault_counts(conditions = '1=1')
    array = []
    find_by_sql(%Q(SELECT COUNT(`detections`.`fault_nature_id`) as counts, `fault_natures`.`name`, `fault_natures`.`id` FROM `fault_natures` LEFT JOIN `detections`ON `detections`.`fault_nature_id` = `fault_natures`.`id` AND #{conditions} GROUP BY `fault_natures`.`name` ORDER BY `fault_natures`.`id` DESC)).each{|item| array << {:id => item.id, :name => item.name, :count => item.counts}}
    array
  end

  def self.find_composite_ids(conditions = '1 = 1', offset = 0, limit = 10)
    Detection
    .unscoped
    .joins("INNER JOIN (SELECT id FROM detections WHERE #{conditions} ORDER BY detect_date DESC, detect_time DESC LIMIT #{limit} OFFSET #{offset}) as a2 using(id)")
    .select('id')
  end

  def self.find_regoin_composite_ids(conditions = '1 = 1', offset = 0, limit = 10)
    Detection
    .unscoped
    .joins("INNER JOIN (SELECT detections.id FROM detections LEFT JOIN substations ON substations.id=detections.substation_id LEFT JOIN regions ON regions.id=substations.region_id WHERE #{conditions} ORDER BY detect_date DESC, detect_time DESC LIMIT #{limit} OFFSET #{offset}) as a2 using(id)")
    .select('id')
  end

  def self.find_and_cache_composite_by_id(id)
    Rails.cache.fetch("composite_id_of_#{id}") do
      fields = [
        'detections.*',
        'substations.region_id',
        'substations.name AS substation_name',
        'device_areas.device_area_name',
        'voltage_levels.name AS voltage_level_name',
        'device_types.name AS device_type_name',
        'devices.local_scene_name AS local_scene_name',
        'devices.phasic AS device_phasic',
        'part_positions.name AS part_position_name',
        'fault_natures.name AS fault_nature_name',
        'fix_methods.name AS fix_method_name',
        'execute_cases.name AS execute_case_name',
        'model_styles.model_style AS model_style',
        'model_styles.name AS model_style_name'
      ]

      detection = Detection
      .joins('LEFT JOIN substations ON substations.id = detections.substation_id')
      .joins('LEFT JOIN device_areas ON device_areas.id = detections.device_area_id')
      .joins('LEFT JOIN voltage_levels ON voltage_levels.id = detections.device_area_voltage_id')
      .joins('LEFT JOIN device_types ON device_types.id = detections.device_type_id')
      .joins('LEFT JOIN model_styles ON model_styles.id = detections.model_style_id')
      .joins('LEFT JOIN devices ON devices.id = detections.device_id')
      .joins('LEFT JOIN part_positions ON part_positions.id = detections.part_position_id')
      .joins('LEFT JOIN fault_natures ON fault_natures.id = detections.fault_nature_id')
      .joins('LEFT JOIN fix_methods ON fix_methods.id = detections.fix_method_id')
      .joins('LEFT JOIN execute_cases ON execute_cases.id = detections.execute_case_id')
      .select(fields).find(id)
      region = Region.find_by_sql("SELECT b.name FROM regions a JOIN regions b WHERE a.id = #{detection.region_id} AND a.parent_id = b.id").first
      detection.company = region.name
      detection
    end
  end

  def find_phasic_compare_ids
    device = Device.find_and_cache_by_id(device_id)
    Detection
    .unscoped
    .where("detections.model_style_id=#{model_style_id} AND detections.device_area_id=#{device_area_id} AND detections.detect_date = '#{detect_date}' AND detections.device_id != #{device_id} AND devices.local_scene_name='#{device.local_scene_name}'")
    .joins("LEFT JOIN devices ON detections.device_id = devices.id")
    .joins('LEFT JOIN fault_natures ON detections.fault_nature_id = fault_natures.id')
    .select('detections.id, detections.detect_date, detections.detect_time, devices.phasic AS device_phasic, fault_natures.name AS fault_nature_name, devices.local_scene_name').order('LENGTH(devices.phasic) ASC, devices.phasic ASC')
  end

  def find_same_device_historiy_ids(offset, limit)
    Detection
    .unscoped
    .where("detections.id != #{id} AND detections.model_style_id=#{model_style_id} AND detections.device_area_id=#{device_area_id} AND detections.device_id = #{device_id} AND detections.part_position_id = #{part_position_id}")
    .joins('LEFT JOIN detection_resources ON detections.id = detection_resources.detection_id')
    .joins('LEFT JOIN devices ON detections.device_id = devices.id')
    .select('detect_date, detect_time, detection_id, phasic AS device_phasic')
    .limit(limit)
    .offset(offset)
    .order('detect_date DESC, detect_time DESC')
  end

  def detect_full_time
    "#{detect_date} #{detect_time.utc.strftime('%H:%M:%S')}"
  end

  def detect_description
    "#{detect_full_time} - #{company} - #{substation_name} - #{device_area_name} - #{device_type_name} - #{model_style} - #{device_phasic} - #{part_position_name} - #{fault_nature_name}"
  end

  def item_title
    "#{company} - #{substation_name} - #{device_area_name} - #{device_type_name} - #{model_style} - #{part_position_name}"
  end
end
