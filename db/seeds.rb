# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = User.create( :email => "admin@local.host", :name => "admin", :password => "123456", :mobile => '13888888888' )
admin.admin = true
admin.save!


fault_degrees = FaultDegree.create( [ { name: '一般' }, { name: '中等' }, { name: '严重' } ] )
execute_cases = ExecuteCase.create( [ { name: '待修' }, { name: '检修进行中' }, { name: '完成检修' } ] )
fix_methods   = FixMethod.create( [ { name: '维修' }, { name: '更换' } ] )
part_positions = PartPosition.create( [ { name: '主体' }, { name: '本体' } ] )
device_area_types = DeviceAreaType.create( [ { name: '间隔' }, { name: '杆号' } ] )

fault_natures = FaultNature.create( [ { name: '正常' }, { name: '关注' }, { name: '一般缺陷' }, { name: '严重缺陷' }, { name: '危急缺陷' } ] )
FaultNature.new do |f|
  f.id = 100
	f.name = '未诊断'
	f.save
end
