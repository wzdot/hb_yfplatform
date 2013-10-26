#coding: utf-8
require_relative 'request_helpers'

include RequestHelpers
describe 'analyse' do
	let(:authed_user) { create_logged_in_user }

	before(:each) do
		@region = FactoryGirl.create(:region)
		@area_region = FactoryGirl.create(:area_region)
		@zone_region = FactoryGirl.create(:zone_region)
		@substation = FactoryGirl.create(:substation)
		@device_type = FactoryGirl.create(:device_type)
		@voltage_level = FactoryGirl.create(:voltage_level)
	end

	it 'should init ztree data' do
		authed_user
		visit "/basic_data/regions/0/get_childs.json?level=-1"
		page.should have_content ActiveSupport::JSON.encode(@region.name)
		visit "/basic_data/regions/1/get_childs.json?level=0"
		page.should have_content ActiveSupport::JSON.encode(@area_region.name)
		visit "/basic_data/regions/2/get_childs.json?level=1"
		page.should have_content ActiveSupport::JSON.encode(@zone_region.name)
		visit "/basic_data/regions/3/get_substations.json?level=2"
		page.should have_content ActiveSupport::JSON.encode(@substation.name)
	end

	it 'should init search box' do
		authed_user
		visit '/analyse'
		page.select @device_type.name, :from => 'query_device_type'
		page.select @voltage_level.name, :from => 'query_voltage_level'
		page.should have_field('begin_date')
		page.should have_field('end_date')
		page.should have_button('btn_submit')
	end

	it 'should find record success' do
		authed_user
		@model_style = FactoryGirl.create(:model_style)
		@device = FactoryGirl.create(:device)
		@part_position = FactoryGirl.create(:part_position)
		@fault_nature = FactoryGirl.create(:fault_nature)
		@fix_method = FactoryGirl.create(:fix_method)
		@execute_case = FactoryGirl.create(:execute_case)
		@fault_degree = FactoryGirl.create(:fault_degree)
		@detect_rule = FactoryGirl.create(:detect_rule)
		@device_area = FactoryGirl.create(:device_area)
		@detection = FactoryGirl.create(:detection)
		visit '/composite/detections.json?device_type=1&voltage_level=1&begin_date=2000-01-01&end_date=2000-12-31&substation_id=1'
		page.should have_content '"totalrecords":1'
		page.should have_content ActiveSupport::JSON.encode(@substation.name)
		page.should have_content ActiveSupport::JSON.encode(@model_style.name)
	end
end