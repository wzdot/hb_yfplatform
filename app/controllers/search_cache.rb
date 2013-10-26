class SearchCache
=begin
	缓存Key遵循[substation_id]_[device_type_id]_[device_area_voltage_id
device_area_voltage_id]_[begin_date]_[end_date]_[fault_ids]_[page_no]
	device_type_id，device_area_voltage_id
device_area_voltage_id，begin_date，end_date未选择时，缺省为零
	begin_date，end_date时间格式为yyyymmdd
	fault_ids格式为id1,id2,id3...
	"rows"=>"10", "page"=>"1", "sidx"=>"id", "sord"=>"asc"
=end
  attr_accessor :substation_id
  attr_accessor :device_type_id
  attr_accessor :device_area_voltage_id
  attr_accessor :begin_date
  attr_accessor :end_date
  attr_accessor :fault_ids
  attr_accessor :page_no
  attr_accessor :ignore_sort
  attr_accessor :page_size
  attr_accessor :order_field
  attr_accessor :order_by
  attr_accessor :ids
  attr_accessor :totalrecords

  attr_accessor :level
  attr_accessor :select_id
  attr_accessor :device_area_id
  attr_accessor :device_voltage

  def initialize
    @ignore_sort ||= true
    @order_field ||= 'id'
    @order_by ||= 'desc'
  end

  def generate_cache_key
    if begin_date > end_date
      temp = end_date
      @end_date = begin_date
      @begin_date = temp
    end
  	begin_date.gsub!('-', '')
  	end_date.gsub!('-', '')
    key = "#{level}_#{select_id}_#{device_area_voltage_id}_#{device_type_id}_#{device_area_voltage_id}_#{device_area_id}_#{begin_date}_#{end_date}_#{fault_ids}_#{page_no}_#{page_size}"
    key << "_#{order_field}_#{order_by}" unless ignore_sort
    Digest::MD5.hexdigest(key)
  end

  def generate_count_cache_key
    if begin_date > end_date
      temp = end_date
      @end_date = begin_date
      @begin_date = temp
    end
    begin_date.gsub!('-', '')
    end_date.gsub!('-', '')
    key = "#{level}_#{select_id}_#{device_area_voltage_id}_#{device_type_id}_#{device_area_voltage_id}_#{device_area_id}_#{begin_date}_#{end_date}_#{fault_ids}"
    key << "_#{order_field}_#{order_by}" unless ignore_sort
    Digest::MD5.hexdigest(key)
  end

  def generate_fault_cache_key
    if begin_date > end_date
      temp = end_date
      @end_date = begin_date
      @begin_date = temp
    end
    begin_date.gsub!('-', '')
    end_date.gsub!('-', '')
    key = "fault_#{level}_#{select_id}_#{device_area_voltage_id}_#{device_type_id}_#{device_area_voltage_id}_#{device_area_id}_#{begin_date}_#{end_date}_#{fault_ids}"
    key << "_#{order_field}_#{order_by}" unless ignore_sort
    Digest::MD5.hexdigest(key)
  end

  def redis_cache_ids
    
  end
end