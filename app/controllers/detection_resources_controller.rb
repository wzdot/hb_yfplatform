class DetectionResourcesController < ApplicationController
  layout 'composite'
  
  active_scaffold :detection_resource do |conf|
    conf.columns = [ :detection, :irimage, :viimage, :params_json, :irp, :irv ]
    conf.update.link.page = true
    conf.create.link.page = true
    #conf.columns[ :detection ].set_link :show, :page => true
    conf.columns[ :detection ].clear_link
  end
end 
