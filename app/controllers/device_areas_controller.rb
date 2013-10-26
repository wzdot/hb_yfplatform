# -*- coding: utf-8 -*-
# 设备区明细：表示每个变电站或线路中实际上安装了哪些设备区
class DeviceAreasController < ApplicationController
  layout 'basic_data'

  active_scaffold :device_area do |conf|
    conf.columns = [ :substation, :device_area_name, :voltage_level ]
    conf.columns[ :substation ].form_ui = :select
    conf.columns[ :voltage_level ].form_ui = :select

    conf.columns[ :substation ].clear_link
    conf.columns[ :voltage_level ].clear_link

    columns.each{|column| column.sort = false}
    # list.cached = true
  end
end 
