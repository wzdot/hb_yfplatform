#coding: utf-8
FactoryGirl.define do
  factory :region do
    name '浙江省电力公司'
    parent_id 0
  end

  factory :area_region, :class => :region do
		name '海宁供电公司'
    parent_id 1
  end

  factory :zone_region, :class => :region do
  	name '变电工区'
    parent_id 2
  end

  factory :substation do
    region_id 3
    name '梦溪坊4栋603'
    voltage_level_id 4
  end
end