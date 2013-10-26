#coding: utf-8

def db_not_null_fields(table_name, table_schema = 'yfplatform_test')
	rs = ActiveRecord::Base.connection.execute("SELECT COLUMN_NAME,DATA_TYPE FROM `information_schema`.`COLUMNS` WHERE `TABLE_SCHEMA`='#{table_schema}' AND `TABLE_NAME`='#{table_name}' AND IS_NULLABLE='NO' ORDER BY COLUMN_NAME")
	{}.tap do |hash|
		rs.each do |field|
			next if field[0] =~ /^(id|updated_at|created_at)$/
			if field[1] =~ /int$/
				hash.merge!({field[0].to_sym => 1})
			elsif field[1] =~ /^date$/
				hash.merge!({field[0].to_sym => '2012-08-08'})
			elsif field[1] =~ /^time$/
				hash.merge!({field[0].to_sym => '20:20:20'})
			else
				hash.merge!({field[0].to_sym => 'yfplatform'})
			end
		end
	end
end

def tablename_to_modelname(table_name)
	str = table_name.singularize
	array = str.split('_')
	"".tap do |name|
		array.each do |item|
			name << item.capitalize
		end
	end
end

def table_of(table_name)
	context "#{table_name}" do
		before(:all) do
			@hash = db_not_null_fields(table_name)
			@model_name = tablename_to_modelname(table_name)
		end

		it 'should be save success when require fields is input' do
			Object::const_get(@model_name).new(@hash).save.should be_true
		end

		it 'should be save failure when require fields is empty' do
			expect{Object::const_get(@model_name).new.save}.to raise_error(ActiveRecord::StatementInvalid)
		end

		it 'should be save failure when record is duplicate' do
			Object::const_get(@model_name).create(@hash)
			expect{Object::const_get(@model_name).new(@hash).save}.to raise_error(ActiveRecord::RecordNotUnique)
		end
	end
end

describe 'scaffold table' do
	table_of('voltage_levels')
	table_of('fault_natures')
	table_of('execute_cases')
	table_of('fault_degrees')
	table_of('fix_methods')
	table_of('part_positions')
	table_of('device_area_types')
	table_of('venders')
	table_of('regions')
	table_of('substations')
	table_of('employees')
	table_of('device_types')
	table_of('model_styles')
	table_of('outlines')
	table_of('detect_rules')
	table_of('device_areas')
	table_of('devices')
	table_of('shoot_sequences')
	table_of('device_area_shoot_sequences')
	table_of('device_shoot_sequences')
	table_of('part_position_shoot_sequences')
	table_of('detections')
	table_of('detection_resources')
	table_of('report_templates')
end