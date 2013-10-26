# -*- coding: utf-8 -*-
class SubstationsController < ApplicationController
  layout 'basic_data'

  active_scaffold :substation do |conf|
    conf.columns = [ :name, :notes, :voltage_level, :region ]   # device_areas
    # conf.create.columns.exclude [ :device_areas ]
    # conf.update.columns.exclude [ :device_areas ]
    conf.columns[ :voltage_level ].form_ui = :select
    conf.columns[ :region ].form_ui = :select

    conf.columns[ :region ].clear_link
    conf.columns[ :voltage_level ].clear_link
  end

  def get_shoot_sequences
    if params[ :id ].to_i == 0 
      sequences = ShootSequence.all
    else
      substation = Substation.find( params[ :id ] )
      sequences = substation.shoot_sequences
    end
 
    json_data = []
    sequences.each do |item|
      a_hash = item.attributes
      json_data += [ a_hash ]
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end

  # 获取substation下所有的设备区
  def get_device_areas
    if params[ :id ]
      substation = Substation.find( params[ :id ] )
    end

    if substation
      device_areas = substation.device_areas;
    end

    json_data = []
    device_areas.each do |item|
      a_hash = item.attributes
      a_hash[ "name" ] = item.device_area.name
      json_data += [ a_hash ]
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end

end 
