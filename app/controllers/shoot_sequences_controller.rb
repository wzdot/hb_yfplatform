# -*- coding: utf-8 -*-

# Gemfile中gem 'rubyzip'后必须要有require => 'zip/zip'
# 否则会找不到zip/zip模块
# gem 'rubyzip', :require => 'zip/zip'
require 'zip/zip'
require 'zipruby'

class ShootSequencesController < ApplicationController
  layout 'task'

  active_scaffold :shoot_sequence do |conf|
    conf.columns = [ :substation, :name , :notes ]

    conf.create.columns = [ :substation, :name, :notes ]
    conf.columns[ :substation ].form_ui = :select
    conf.columns[ :substation ].clear_link
  end

  def define_dashboard
    #render :layout => 'shoot-sequence'
  end

  # 新增拍摄顺序节点
  def deal_tree_items
    category = params[:category] || 'list'
    if category == 'list'
      parent_id = params[:id]
      sequences = ShootSequence.find_all_by_substation_id(parent_id)
      data = []
      sequences.each do |sequence|
        data << {:parent_id => parent_id, :id => sequence.id, :name => sequence.name}
      end
    end

    if category == 'add'
      parent_id = params[:id]
      name = params[:name]
      instance = ShootSequence.new(:substation_id => parent_id, :name => params[:name])
      if instance.save
        data = {:status => 0, :parent_id => parent_id, :id => instance.id, :name => instance.name}
      else
        data = {:status => 1, :parent_id => 0, :id => 0, :name => ''}
      end
    end

    if category == 'edit'
      id = params[:id]
      instance = ShootSequence.find(id)
      instance.name = params[:name]
      if instance.save
        data = {:status => 0}
      else
        data = {:status => 1}
      end
    end

    if category == 'delete'
      id = params[:id]
      ShootSequence.delete(id)
      data = {:status => 0}
    end

    respond_to do |format|
      format.json { render json: data }
    end
  end

  def selected_shoot_sequence
    id = params[:id]
    sequence = ShootSequence.find(id)
    respond_to do |format|
      format.json { render json: sequence.tree_items }
    end
  end

  def optional_device_area
    id = params[:id]
    sequence = ShootSequence.find(id)
    respond_to do |format|
      format.json { render json: sequence.optional_device_area }
    end
  end

  def optional_device
    area_id = params[:area_id]
    used_ids = params[:used_ids].split(',').map { |s| s.to_i }
    respond_to do |format|
      format.json { render json: ShootSequence.optional_device(area_id, used_ids) }
    end
  end

  def optional_part_position
    used_ids = params[:used_ids].split(',').map { |s| s.to_i }
    respond_to do |format|
      format.json { render json: ShootSequence.optional_part_position(used_ids) }
    end
  end


  def get_device_areas
    if params[ :id ].to_i > 0
      sequence = ShootSequence.find( params[ :id ] )
      if sequence
        device_areas = sequence.device_area_shoot_sequences
      end
    end

    json_data = []
    if( device_areas )
      device_areas.each do |item|
        a_hash = item.attributes
        a_hash[ "isParent" ] = true
        a_hash[ "name" ] = item.device_area.device_area_name
        a_hash[ "node_type" ] = "device_area" 
        json_data += [ a_hash ]
      end
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end  

  # 获取某一拍摄顺序下，所有待选择的设备区( 对应的substation下的所有设备区 - 拍摄顺序下已有的设备区 )
  def get_device_areas_to_select
    if params[ :id ].to_i > 0
      sequence = ShootSequence.find( params[ :id ] )
    end

    if sequence
      exist_device_areas = sequence.device_area_shoot_sequences
      all_device_areas = sequence.substation.device_areas
      
      exist_ids = []
      exist_device_areas.each do |item|
        exist_ids += [ item.device_area_id ]
      end

      device_areas_to_select = []
      all_device_areas.each do |item|
        if !( exist_ids.include?( item.id ) )
          device_areas_to_select += [ item ]
        end
      end
    end

    json_data = []
    if device_areas_to_select
      device_areas_to_select.each do |item|
        a_hash = item.attributes
        a_hash[ "device_area_id" ] = item.id
        a_hash[ "name" ] = item.device_area_name
        a_hash[ "isParent" ] = false
        a_hash[ "node_type" ] = "device_area"
        json_data += [ a_hash ]
      end
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end

  def create_with_json
    if params[ :id ]
      sequence = ShootSequence.find( params[ :id ] )
    end

    if sequence
      sequence.device_area_shoot_sequences.each do |item|
        item.device_shoot_sequences.each do |subitem|
          subitem.destroy
        end

        item.destroy
      end
  
      shoot_sequence_details = JSON.parse( params[ "shoot_sequence_details" ] )

      device_area_order = 1
      shoot_sequence_details.each do |detail|
        device_area_shoot_sequence = DeviceAreaShootSequence.create( :shoot_sequence_id => sequence.id, :order_num => device_area_order, :device_area_id => detail[ "device_area_id" ] )
        children = detail[ "children" ]
        #logger.debug "children: #{ children }"

        if children
          device_order = 1
          children.each do |subitem|
            #logger.debug "device: #{ subitem }"
            DeviceShootSequence.create( :shoot_sequence_id => device_area_shoot_sequence.shoot_sequence_id, :device_area_id => detail[ "device_area_id" ], :order_num => device_order, :device_id => subitem[ "device_id" ] )
            device_order = device_order + 1
          end
        end

        device_area_order = device_area_order + 1
      end
    end

    respond_to do |format|
      #这3种方式都未能使ajax.post的返回状态为成功，原因未知
      #format.json { render :text => "ok", :status => 200 }
      #format.json { render json: "ok" }
      format.json { head :ok }
    end
  end

  def prepare_sqlite_db_struct
    ActiveRecord::Schema.define do
      @connection = MachineShootSequence.connection
      if MachineShootSequence.table_exists?
        drop_table :machine_shoot_sequences
      end

      create_table :machine_shoot_sequences do |t|
        t.column :substation_id, :integer
        t.column :substation_name, :string
        t.column :substation_voltage_level, :string
        t.column :shoot_sequence_id, :integer
        t.column :shoot_sequence_name, :string
        t.column :device_area_order_num, :integer
        t.column :device_area_id, :integer
        t.column :device_area_name, :string
        t.column :device_area_voltage_level, :string
        t.column :device_order_num, :integer
        t.column :device_id, :integer
        t.column :device_type, :string
        t.column :device_name, :string
        t.column :model_style, :string
        t.column :phasic, :string
        t.column :device_voltage_level, :string
        t.column :device_local_scene_name, :string
        t.column :part_position_id, :integer
        t.column :part_position, :string
      end

      #ActiveRecord::Base.establish_connection( "#{ RAILS_ENV }" )
    end
  end


  def export_shoot_sequence_data_to_sqlite sequence_id
    sequence = ShootSequence.find sequence_id
    return if sequence.blank? 

    device_area_shoot_sequences = DeviceAreaShootSequence.where( "shoot_sequence_id = ?", sequence_id )
    device_area_shoot_sequences.each do |item|
      device_shoot_sequences = DeviceShootSequence.where( "shoot_sequence_id = ? AND device_area_id = ?", sequence_id, item.device_area_id )
      device_shoot_sequences.each do |subitem|
        part_position_sequences = PartPositionShootSequence.where( "shoot_sequence_id = ? AND device_area_id = ? AND device_id = ?", sequence_id, item.device_area_id, subitem.device_id )
        index = 0;
        while( index <= part_position_sequences.size ) 
          exp_item = MachineShootSequence.new
          exp_item.substation_id = sequence.substation.id
          exp_item.substation_name = sequence.substation.name
          exp_item.substation_voltage_level = sequence.substation.voltage_level.name
          exp_item.shoot_sequence_id = sequence.id
          exp_item.shoot_sequence_name = sequence.name
          #
          exp_item.device_area_order_num = item.order_num
          exp_item.device_area_id = item.device_area_id
          exp_item.device_area_name = item.device_area.device_area_name
          exp_item.device_area_voltage_level = item.device_area.voltage_level.name
          #
          exp_item.device_order_num = subitem.order_num
          exp_item.device_id = subitem.device_id
          exp_item.device_type = subitem.device.model_style.device_type.name
          exp_item.device_name = subitem.device.model_style.name
          exp_item.model_style = subitem.device.model_style.model_style
          exp_item.phasic = subitem.device.phasic
          exp_item.device_voltage_level = subitem.device.voltage_level.name
          exp_item.device_local_scene_name = subitem.device.local_scene_name

          # 如果指定了部位，则找part_position_shoot_sequences表
          unless part_position_sequences.blank?
            exp_item.part_position_id = part_position_sequences[ index ].part_position_id
            exp_item.part_position_name = part_position_sequences[ index ].part_position.name
          end

          exp_item.save
          index = index + 1
        end #while

      end #subitem
    end #item
  end

  def download_task_pkg
    shoot_sequence_id = params[ :id ]
    # 准备好数据库结构
    prepare_sqlite_db_struct
    # 将一些资料输出到sqlite3格式的数据库中
    export_shoot_sequence_data_to_sqlite( shoot_sequence_id ) if shoot_sequence_id
    
    files_list = Dir.glob( "public/task_pkg/*" )
    do_download_task_pkg( files_list )
  end

  def do_download_task_pkg( files_list )
    return if files_list.blank?

    zip_file_name = "task_pkg.zip"

    # zip it
    t = Tempfile.new( "task-temp-filename-#{ Time.now }" )
    Zip::ZipOutputStream.open( t.path ) do |z|
      files_list.each do |file|
        title = file.clone
        title.slice!( "public/task_pkg/" )
        #title += ".jpg" unless title.end_with?( ".jpg" )
        z.put_next_entry( title )
        z.print IO.read( file )  #path
      end
      
      title = "outlines/变电工区-110KV-海昌变电站-山海1269线-线路间隔-山海1269线线路-避雷器-B.jpg"
      #title = "\xe7\x89\xb9\xe4\xbb\xb7\xe6\x9c\xba\xe7\xa5\xa8"  #"特价机票"
      file = "public/uploads/outlines/变电工区-110KV-海昌变电站-山海1269线-线路间隔-山海1269线线路-避雷器-B.jpg"
      z.put_next_entry( title )
      z.print IO.read( file )
    end

=begin
    #using ZipRuby #中文文件名会乱码
    ZipRuby::Archive.open( t.path, ZipRuby::CREATE ) do |z|
      files_list.each do |file|
        title = file.clone
        title.slice!( "public/task_pkg/" )
        #title += ".jpg" unless title.end_with?( ".jpg" )
        z.add_file( file )
      end
    end
=end

=begin
    # 直接调用系统命令的方法
    temp_file_name = "task-temp-filename.zip"
    system "zip -r #{ temp_file_name } public/task_pkg/"
    send_file temp_file_name, :type => 'application/zip', :disposition => 'attachment', :filename => zip_file_name
=end
    #download
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => zip_file_name


    t.close
  end

end 
