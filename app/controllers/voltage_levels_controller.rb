# -*- coding: utf-8 -*-
class VoltageLevelsController < ApplicationController
  layout 'data_dictionary'

  active_scaffold :voltage_level do |conf|
    #conf.create.label = :create_voltage_level
    #conf.update.label = :update_voltage_level #这句不起作用, 设置后edit的标题仍是"Update Model"
  end
end 
