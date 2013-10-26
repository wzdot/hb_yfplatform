class EmployeesController < ApplicationController
  layout 'data_dictionary'

  active_scaffold :employee do |conf|
    conf.columns = [ :name, :email, :mobile, :tel, :region ]
    conf.columns[ :region ].form_ui = :select
    conf.columns[ :region ].clear_link
  end
end 
