# -*- coding: utf-8 -*-
class DeviceAreaShootSequencesController < ApplicationController
  layout 'task'

  active_scaffold :device_area_shoot_sequence do |conf|
    conf.columns = [ :substation, :shoot_sequence, :order_num, :device_area ] #, :device_shoot_sequences ]

    conf.columns[ :shoot_sequence ].form_ui = :select
    conf.columns[ :device_area ].form_ui = :select

    conf.columns[ :shoot_sequence ].clear_link
    conf.columns[ :device_area ].clear_link
  end

  # 获取其下的所有的设备
  def get_device_shoot_sequences
    if params[ :id ]
      device_area_shoot_sequence = DeviceAreaShootSequence.find( params[ :id ] )
      if device_area_shoot_sequence
        device_shoot_sequences = device_area_shoot_sequence.device_shoot_sequences
      end
    end

    json_data = []
    if device_shoot_sequences
      device_shoot_sequences.each do |item|
        a_hash = item.attributes
        device = item.device

        if device
          model_style = device.model_style
          device_type = model_style.device_type
          name = device_type.name + " " + model_style.model_style + " " + model_style.name + " " + device.phasic
          a_hash[ "name" ] = name
          a_hash[ "node_type" ] = "device"
          json_data += [ a_hash ]
        end

      end
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end  


  # 获取某一substation下,某一设备区下，所有待选择的设备( 对应的substation及设备区下的所有设备 - 拍摄顺序下已有的设备 )
  def get_devices_to_select
    if params[ :id ]
      device_area_shoot_sequence = DeviceAreaShootSequence.find( params[ :id ] )
    end

    substation_id = 0  #必须在这里定义一下，否则会出错

    if device_area_shoot_sequence
      exist_device_shoot_sequences = device_area_shoot_sequence.device_shoot_sequences
      device_area_id = device_area_shoot_sequence.device_area_id

      substation_id = device_area_shoot_sequence.shoot_sequence.substation_id

      conditions = "device_area_id = #{ device_area_id }"
      all_device_shoot_sequences = Device.find( :all, :conditions => conditions )

      exist_ids = []
      exist_device_shoot_sequences.each do |item|
        exist_ids += [ item.device_id ]
      end

      devices_to_select = []
      all_device_shoot_sequences.each do |item|
        if !( exist_ids.include?( item.id ) )
          devices_to_select += [ item ]
        end
      end
    end

    json_data = []
    if devices_to_select
      devices_to_select.each do |item|
        a_hash = item.attributes
        a_hash[ "device_id" ] = item.id
        model_style = item.model_style
        a_hash[ "name" ] = model_style.device_type.name + " " + model_style.model_style + " " + model_style.name + " " + item.phasic
        a_hash[ "node_type" ] = "device"
        json_data += [ a_hash ]
      end
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end

end 
