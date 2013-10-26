#coding: utf-8
FactoryGirl.define do
	factory :detection do
		detect_date '2000-08-08'
		detect_time '12:00:00'
		device_id 1
		part_position_id 1
		fault_nature_id 1
		fixed_date '2000-08-10'
		fix_method_id 1
		execute_case_id 1
		fault_degree_id 1
		detect_rule_id 1
		running_voltage 120
		electrical_current 15
    substation_id 1
    device_area_id 1
    device_area_voltage_id 1
    device_type_id 1
    model_style_id 1
	end

	factory :model_style do
		model_style 'Container-17/46'
		name '防潮箱'
		device_type_id 1
	end

	factory :device do
		device_area_id 1
		model_style_id 1
    phasic 'MyString'
	end

	factory :device_type do
    name '办公工具'
  end

  factory :part_position do
    name '主体'
  end

  factory :fault_nature do
  	name '危急缺陷'
  end

  factory :fix_method do
  	name '更换'
  end

  factory :execute_case do
  	name '完成检修'
  end

  factory :fault_degree do
  	name '严重'
  end

  factory :detect_rule do
  	outline_id 1
  	fault_nature_id 1
  	order_num 1
  	rule_title '危急'
  end

  factory :device_area do
  	substation_id 1
  	voltage_level_id 1
  	device_area_name '大厅'
  end
end