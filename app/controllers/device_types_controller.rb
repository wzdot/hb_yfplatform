class DeviceTypesController < ApplicationController
  layout 'data_dictionary'

  active_scaffold :device_type do |conf|
    conf.columns = [ :name, :notes, :parent ]
    conf.columns[ :parent ].form_ui = :select

    conf.columns[ :parent ].clear_link
  end
end 
