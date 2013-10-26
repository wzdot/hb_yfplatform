class ModelStylesController < ApplicationController
  layout 'basic_data'

  active_scaffold :model_style do |conf|
    conf.columns = [ :model_style, :name, :device_type, :voltage_level, :notes ]
    conf.columns[ :device_type ].form_ui = :select
    conf.columns[ :device_type ].clear_link
    conf.columns[ :voltage_level ].form_ui = :select
    conf.columns[ :voltage_level ].clear_link

    columns.each{|column| column.sort = false}
    # list.cached = true
  end

  def outline
    @model_style = ModelStyle.find( params[ :id ] )
  end
end 
