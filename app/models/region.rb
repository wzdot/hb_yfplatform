require 'tree_node'
class Region < ActiveRecord::Base
  expired_active_scaffold_cache
  belongs_to :parent, :class_name => "Region"
  has_many   :childs, :class_name => "Region", :foreign_key => "parent_id"
  has_many   :substations
  has_many   :employees


  def self.tree_items
  	regions = {}
  	all.each do |item|
  		node = Node.new(item.id, item.name, item.parent_id)
  		regions[node.id] = node
  	end
  	root = []
  	regions.each do |id, node|
  		root << regions[id] and next if node.parent_id == 0
  		regions[node.parent_id].add(node)
  	end

  	substations = {}
  	Substation.all.each do |item|
  		node = Node.new(item.id, item.name, item.region_id)
  		substations[node.id] = node
  		regions[node.parent_id].add(node)
  	end

  	sequences = {}
  	ShootSequence.all.each do |item|
  		node = Node.new(item.id, item.name, item.substation_id, false)
  		substations[node.parent_id].add(node)
  	end

  	root
  end

  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("region_id_of_#{id}") do
      Region.find(id)
    end
  end
end
