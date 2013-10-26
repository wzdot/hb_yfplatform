# -*- coding: utf-8 -*-
class RegionsController < ApplicationController
  layout 'basic_data'

  active_scaffold :region do |conf|
    conf.columns = [ :name, :notes, :parent ]
    conf.columns[ :parent ].form_ui = :select

    conf.columns[ :parent ].clear_link
    # conf.list.always_show_search = true
  end

  def get_children( parent_id = -1, level = 0 )
    if parent_id < 0 
      items = Region.find( :all, :conditions => [ "parent_id < 1 OR parent_id IS NULL" ] )
    else 
      items = Region.find( :all, :conditions => [ "parent_id = ?", parent_id ] )
    end

    json_data = []
    items.each do |item|
      a_hash = item.attributes
      a_hash[ "isParent" ] = true if level < 4

      a_hash[ "children" ] = get_children( item.id, level + 1 )
      
      json_data += [ a_hash ]
    end

    return json_data 
  end

  # 配合zTree一次性动态加载数据
  def get_tree_datas
    json_data = get_children
 
    respond_to do |format|
      format.json { render json: json_data }
    end
  end

  # 配合zTree异步方式加载数据
  def get_childs
    if params[ :id ].to_i == 0 
      childs = Region.find( :all, :conditions => [ "parent_id < 1 OR parent_id IS NULL" ] )
    else
      childs = Region.find( :all, :conditions => [ "parent_id = ?", params[:id] ] )
    end
 
    json_data = []
    childs.each do |item|
      a_hash = item.attributes
      if params[ :level ].to_i < 4
        a_hash[ "isParent" ] = true
      end
      json_data += [ a_hash ]
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end


  def get_substations
    if params[ :id ].to_i == 0 
      substations = Substation.all
    else
      region = Region.find( params[ :id ] )
      substations = region.substations
    end
 
    json_data = []
    substations.each do |item|
      a_hash = item.attributes
      a_hash[ "isParent" ] = false #true
      json_data += [ a_hash ]
    end

    respond_to do |format|
      format.json { render json: json_data }
    end
  end


  def load_tree_items
    respond_to do |format|
      format.json { render json: Region.tree_items }
    end
  end
end 
