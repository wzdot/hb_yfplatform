#coding: utf-8
require 'tree_node'

class ShootSequence < ActiveRecord::Base
  belongs_to :substation
  # has_many   :device_area_shoot_sequences, :select => 'shoot_sequence_id, device_area_id'

  def selected_device_area
    DeviceAreaShootSequence.select('shoot_sequence_id, device_area_id').find_all_by_shoot_sequence_id(id)
  end

  def optional_device_area
    used_ids = selected_device_area.collect(&:device_area_id)
    areas = DeviceArea.select("id, device_area_name").find_all_by_substation_id(self.substation_id).reject{|item| used_ids.include?(item.id)}
    [].tap do |nodes|
      areas.each do |area|
        nodes << Node.new(area.id, area.device_area_name, 0, false)
      end
    end
  end

  def self.optional_device(device_area_id, used_ids)
    areas = Device.select("id, local_scene_name").find_all_by_device_area_id(device_area_id).reject{|item| used_ids.include?(item.id)}
    [].tap do |nodes|
      areas.each do |area|
        nodes << Node.new(area.id, area.local_scene_name, 0, false)
      end
    end
  end

  def self.optional_part_position(used_ids)
    parts = PartPosition.select("id, name").reject{|item| used_ids.include?(item.id)}
    [].tap do |nodes|
      parts.each do |part|
        nodes << Node.new(part.id, part.name, 0, false)
      end
    end
  end


  def tree_items
    area_map = DeviceArea.select("id, device_area_name").inject({}){|h, item| h[item.id] = item; h}
    device_map = Device.select("id, local_scene_name").inject({}){|h, item| h[item.id] = item; h}
    part_map = PartPosition.select("id, name").inject({}){|h, item| h[item.id] = item; h}
    nodes = []

    areas = selected_device_area
    areas.each do |area|
      id = area.device_area_id
      name = area_map[id].device_area_name
      area_node = Node.new(id, name, 0)
      devices = area.selected_device
      devices.each do |device|
        id = device.device_id
        name = device_map[id].local_scene_name
        device_node = Node.new(id, name, area_node.id)

        parts = device.selected_part_position
        parts.each do |part|
          id = part.part_position_id
          name = part_map[id].name
          device_node.add(Node.new(id, name, device_node.id, false))
        end
        area_node.add(device_node)
      end
      nodes << area_node
    end
    nodes
  end
end
