class DevicesController < ApplicationController
  respond_to :html, :json

  layout 'basic_data'

  active_scaffold :device do |conf|
    conf.columns = [ :device_area, :device_type, :device_name, :model_style, :phasic, :local_scene_name ]
    conf.columns[ :device_area ].form_ui = :select
    conf.columns[ :model_style ].form_ui = :select

    conf.columns[ :device_area ].clear_link
    conf.columns[ :model_style ].clear_link

    conf.create.columns.exclude [ :device_type, :device_name ]
    conf.update.columns.exclude [ :device_type, :device_name ]

    columns.each{|column| column.sort = false}
  end
end 
