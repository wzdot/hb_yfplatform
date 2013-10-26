#coding: utf-8
desc "临时删除荆门供电公司配电中心"
task :jmpd => :environment do
	line = Region.find_by_name('荆门供电公司配电中心')
	line.destroy
end

desc '将KV修改为kV'
task :down_kv => :environment do
	sql = "UPDATE `voltage_levels` SET `voltage_levels`.`name` = REPLACE(`voltage_levels`.`name`, SUBSTRING(`voltage_levels`.`name`, LOCATE('KV', `voltage_levels`.`name`), 2), 'kV')
"
	ActiveRecord::Base.connection.execute(sql)
end

desc '修改相对温度为相对湿度'
task :xdsd => :environment do
	sql = "UPDATE `detection_resources` SET `detection_resources`.`params_json` = REPLACE(`detection_resources`.`params_json`, SUBSTRING(`detection_resources`.`params_json`, LOCATE('相对温度', `detection_resources`.`params_json`), 4), '相对湿度')"
	ActiveRecord::Base.connection.execute(sql)
end

desc '修改变电运行中心为变电，输电中心为输电，配电中心为配电'
task :sczx => :environment do
	conn = ActiveRecord::Base.connection
	sql = "UPDATE `regions` SET `regions`.`name` = '变电' WHERE `regions`.`name` = '变电运行中心' OR `regions`.`name` = '变电中心'"
	conn.execute(sql)
	sql = "UPDATE `regions` SET `regions`.`name` = '输电' WHERE `regions`.`name` = '输电中心'"
	conn.execute(sql)
	sql = "UPDATE `regions` SET `regions`.`name` = '配电' WHERE `regions`.`name` = '配电中心'"
	conn.execute(sql)
end