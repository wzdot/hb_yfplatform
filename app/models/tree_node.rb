class Node
	attr_accessor :id
	attr_accessor :name
	attr_accessor :parent_id
	attr_accessor :isParent
	attr_reader :children

	def initialize(id, name, parent_id, is_parent = true)
		@id, @name, @parent_id, @isParent = id, name, parent_id, is_parent
		@children = []
	end

	def add(node)
		children << node
	end
end