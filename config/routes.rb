# -*- coding: utf-8 -*-
require 'sidekiq/web'
Yfplatform::Application.routes.draw do
  get "tasks/index"

  get "ztree_demo/index"
  # get "ztree_demo/data"

  mount Sidekiq::Web => '/sidekiq'

  use_doorkeeper

  captcha_route

  resources :report_templates

  resources :detect_rules do as_routes end
  resources :outlines do as_routes end
  resources :venders do as_routes end

  #-------------------------------------------------------
  match 'detections/batchimport'


  get 'about', :to => 'pages#about'
  get 'contact', :to => 'pages#contact'
  get 'users_center' => 'admin/users#index'

  scope :path => 'uploadify' do
    get 'basic_data' => 'basic_data_uploadify#index'
    post 'basic_data/import' => 'basic_data_uploadify#import'
    post 'basic_data/execute' => 'basic_data_uploadify#execute'
    get 'basic_data/progress/:progress_id' => 'basic_data_uploadify#progress'
    get 'shoot_data' => 'shoot_data_uploadify#index'
    post 'shoot_data/import' => 'shoot_data_uploadify#import'
  end
  #resources :users do as_routes end
  #match 'users' => 'users#index'
  #match 'users/:id' => 'users#show', :as => :user

  namespace :admin do
    resources :users do
      member do
        put :block
        put :unblock
      end

      collection do
        post 'add_role_user'
        post 'edit_role_user'
      end
    end
  end

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations", :passwords => "passwords"}
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_up", :to => "users#new"
    get "sign_out", :to => "devise/sessions#destroy"
    get "users/page_show_extra" => "sessions#page_show_extra"
    get "users/sms_code" => "sessions#sms_code"
    get 'users/automatic(/:email)', :to => 'sessions#automatic'
    get 'users/timeout_redirect', :to => "sessions#timeout_redirect"
  end

  # 数据词典模块 --------------------------------------------------
  scope :path => "data_dictionary" do
    [ :voltage_levels, :fault_natures, :execute_cases, :fault_degrees, :fix_methods, :part_positions, :employees, :device_area_types, :device_types ].each do |res|
      resources res do as_routes end
    end

    # root :to => 'pages#data_dictionary'  
    root :to => 'voltage_levels#index'  
  end

  scope '/api/data_dictionary', defaults: {format: :json} do
    resources :voltage_levels, :fault_natures, :execute_cases, :fault_degrees, :fix_methods, :part_positions, :employees, :device_area_types, :device_types
  end

  # 基础数据模块 --------------------------------------------------
  scope :path => "basic_data" do
    match 'regions/get_tree_datas' => 'regions#get_tree_datas'
    match 'regions/:id/get_childs' => 'regions#get_childs'
    match 'regions/:id/get_substations' => 'regions#get_substations'
    match 'substations/:id/get_shoot_sequences' => 'substations#get_shoot_sequences'
    match 'regions/:id/get_device_areas' => 'regions#get_device_areas'

    match 'model_styles/:id/outline' => 'model_styles#outline'
    get 'regions/load_tree_items' => 'regions#load_tree_items', :defaults => { :format => 'json' }

    [ :regions, :substations, :model_styles, :device_areas, :devices ].each do |res|
      resources res do as_routes end
    end

    # root :to => 'pages#basic_data' 
    root :to => 'regions#index'   
  end

  scope '/api/basic_data', defaults: {format: :json} do
    resources :regions, :substations, :model_styles, :device_areas, :devices
  end

  scope :path => 'rules' do
    root :to => 'rules#index'
  end

  scope :path => 'tasks' do
    root :to => 'tasks#index'
  end

  #----------------------------------------------------------------
  # 任务包制作模块
  scope :path => "task" do
    get   'shoot_sequences/download_task_pkg/:id', :to => 'shoot_sequences#download_task_pkg'
    get   'shoot_sequences/define_dashboard', :to => 'shoot_sequences#define_dashboard'
    match 'shoot_sequences/:id/get_device_areas' => 'shoot_sequences#get_device_areas'
    match 'shoot_sequences/:id/get_device_areas_to_select' => 'shoot_sequences#get_device_areas_to_select'
    match 'shoot_sequences/create_with_json' => 'shoot_sequences#create_with_json'

    match 'device_area_shoot_sequences/:id/get_device_shoot_sequences' => 'device_area_shoot_sequences#get_device_shoot_sequences'
    match 'device_area_shoot_sequences/:id/get_devices_to_select' => 'device_area_shoot_sequences#get_devices_to_select'

    get 'deal_tree_items/:category/:id(/:name)', :to => 'shoot_sequences#deal_tree_items', :defaults => { :format => 'json' }
    get 'selected_shoot_sequence/:id', :to => 'shoot_sequences#selected_shoot_sequence', :defaults => { :format => 'json' }
    get 'optional_device_area/:id', :to => 'shoot_sequences#optional_device_area', :defaults => { :format => 'json' }
    get 'optional_device/:area_id/:used_ids', :to => 'shoot_sequences#optional_device', :defaults => { :format => 'json' }
    get 'optional_part_position/:used_ids', :to => 'shoot_sequences#optional_part_position', :defaults => { :format => 'json' }


    [ :shoot_sequences, :device_area_shoot_sequences, :device_shoot_sequences, :part_position_shoot_sequences ].each do |res|
      resources res do as_routes end
    end
 
    root :to => 'pages#task'
  end
 
  # 诊断规则及轮廓分析设置模块
  scope :path => "rule" do
    [ ].each do |res|
      resources res do as_routes end
    end
    
    root :to => "pages#rule"
  end

  # 缺陷诊断模块
  scope :path => "analyse" do
    [ ].each do |res|
      resources res do as_routes end
    end
    
    root :to => "pages#analyse"
  end

  # 批量报告生成模块
  scope :path => "report" do
    [ ].each do |res|
      resources res do as_routes end
    end
    
    root :to => "pages#report"
  end

  get 'download/report/:id/:template' => 'report_templates#piece_of_paper', :as => 'download_paper'

  # 综合数据库管理模块
  scope :path => "composite" do
    get 'detections/role_tree' => 'detections#role_tree'
    get 'detections/admin_tree' => 'detections#admin_tree'
    get 'detections/device_types(/:voltage)' => 'detections#device_types'
    get 'detections/history/:id(/:page_no)(/:page_size)' => 'detections#history', :defaults => { :format => 'json' }
    get 'detections/redo_task/:ids' => 'detections#redo_task', :defaults => { :format => 'json' }
    
    [ :detections, :detection_resources ].each do |res|
      resources res do as_routes end
    end
    # post 'detection/retrieval_data' => 'detections#retrieval_data'
    # get 'detection/role_tree' => 'detections#role_tree'
    root :to => "pages#composite"
  end

  scope '/api/composite', defaults: {format: :json} do
    post 'detections' => 'detections#index'
    post 'detections/faults_search' => 'detections#faults_search'
    [ :detections ].each do |res|
      resources res do as_routes end
    end
  end

  scope :path => "irp_slider" do
    root :to => 'slides#irp_slider' 
  end

  resources :special do
    collection do
      get 'lines/:parent_id', :action => 'lines', :defaults => { :format => 'json' }
      get 'substation_voltages/:region_id', :action => 'substation_voltages', :defaults => { :format => 'json' }
      get 'substations/:line_id/:voltage_level_id', :action => 'substations', :defaults => { :format => 'json' }
      get 'device_area_voltages/:substation_id', :action => 'device_area_voltages', :defaults => { :format => 'json' }
      get 'device_areas/:substation_id/:voltage_level_id', :action => 'device_areas', :defaults => { :format => 'json' }
      get 'device_types/:device_area_id', :action => 'device_types', :defaults => { :format => 'json' }
      get 'model_styles/:device_area_id/:device_type_id', :action => 'model_styles', :defaults => { :format => 'json' }
      get 'devices/:device_area_id/:model_style_id', :action => 'devices', :defaults => { :format => 'json' }
      get 'part_positions', :action => 'part_positions', :defaults => { :format => 'json' }

      # get 'add_device_area_voltage/:substation_id/:voltage_level', :action => 'add_device_area_voltage', :defaults => { :format => 'json' }
      get 'add_device_area/:substation_id/:voltage_level_id/:device_area_name', :action => 'add_device_area', :defaults => { :format => 'json' }
      get 'add_device_type/:device_type', :action => 'add_device_type', :defaults => { :format => 'json' }
      get 'add_model_style/:device_type_id/:voltage_level_id/:model_style', :action => 'add_model_style', :defaults => { :format => 'json' }
      get 'add_device/:device_area_id/:model_style_id/:name', :action => 'add_device', :defaults => { :format => 'json' }
      get 'add_part_position/:name', :action => 'add_part_position', :defaults => { :format => 'json' }

      post 'import', :action => 'import'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#analyse'
  #root :to => 'pages#composite'


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
