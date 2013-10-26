
class DeviceShootSequencesController < ApplicationController
  layout 'task'

  active_scaffold :device_shoot_sequence do |conf|
    conf.columns = [ :substation, :shoot_sequence, :device_area, :order_num, :device ]
    
    conf.columns[ :substation ].form_ui = :select
    conf.columns[ :shoot_sequence ].form_ui = :select
    conf.columns[ :device_area ].form_ui = :select
    conf.columns[ :device ].form_ui = :select

    conf.columns[ :shoot_sequence ].clear_link
    conf.columns[ :device_area ].clear_link
    conf.columns[ :device ].clear_link
    
    conf.columns[ :shoot_sequence ].sort = false
    conf.columns[ :device_area ].sort = false
    conf.columns[ :order_num ].sort = false
    conf.columns[ :device ].sort = false
    
    #conf.list.sorting = [ { :shoot_sequence_id => :asc}, { device_area_id => :asc }, { :order_num => :asc} ]
  end
end 
