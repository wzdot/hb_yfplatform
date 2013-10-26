#coding: utf-8
require_relative 'request_helpers'

include RequestHelpers

def run_item_uri(prefix, array)
	array.each do |item|
		it "#{item[0]} should be valid" do
			authed_user
			visit "/#{prefix}/#{item[0]}"
			page.find('.main-content').should have_content(item[1])
		end
	end
end

describe 'data_dictionary' do
	let(:authed_user) { create_logged_in_user }
	array = [["voltage_levels", "电压等级"], ["fault_natures", "缺陷性质"], ["execute_cases", "执行情况"], ["fault_degrees", "缺陷程度"], ["fix_methods", "消缺方式"], ["part_positions", "部位"], ["employees", "员工"], ["device_area_types", "设备区类型"], ["device_types", "设备类型"]]
	run_item_uri("data_dictionary", array)


	# it "check submod's link" do
		# get_submod_list('data_dictionary')
		# authed_user
		# visit "/data_dictionary"
		# html = page.html
		# body = html.match(/<div class="container-fluid">(.+?)<\/div>/m)[0]
		# p body.scan(/<a.*href="(.+?)".*>(.+?)<\/a>/u)
		# body.scan(/<a.*href="(.+?)".*>(.+?)<\/a>/u).each do |a|
		# 	describe "#{a[0]}" do
		# 		it 'should be valid' do
		# 			visit a[0]
		# 			page.find('.main-content').should have_content(a[1])
		# 		end
		# 	end
		# end
	# end
end



describe 'basic_data' do
	let(:authed_user) { create_logged_in_user }

	array = [["regions", "区域"], ["substations", "变电站或线路"], ["model_styles", "设备型号"], ["device_areas", "设备区"], ["devices", "设备明细"]]
	run_item_uri("basic_data", array)

	# it "check submod's link" do
	# 	get_submod_list('basic_data')
	# end
end

# def get_submod_list(url)
# 		authed_user
# 		visit "/#{url}"
# 		html = page.html
# 		body = html.match(/<div class="container-fluid">(.+?)<\/div>/m)[0]
# 		body.scan(/<a.*href="(.+?)".*>(.+?)<\/a>/u).each do |a|
# 			valid_module_title(a[0], a[1])
# 		end
# end

# def valid_module_title(url, title)
# 	describe "#{url}" do
# 		let(:authed_user) { create_logged_in_user }
# 		it 'should be valid' do
# 			authed_user
# 			visit url
# 			page.find('.main-content').should have_content(title)
# 		end
# 	end
# end