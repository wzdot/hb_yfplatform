#coding: utf-8
desc "批量更新detection_resources表中的irimage_md5和irp_md5值"
task :rebuild_resource_md5 => :environment do
  # DetectionResource.select('id, irimage_file_name, irp_file_name, irjson_file_name, irjson_file_size, detection_id, irimage_md5, irp_md5').find_each do |resource|
  DetectionResource.find_each do |resource|
    detection = Detection.select('substation_id').find_by_id(resource.detection_id)
    if detection
      substation = Substation.select('id, name').find_by_id(detection.substation_id)
      if substation
        unless resource.irimage_file_name.blank?
          md5_irimage_name = DetectionResource.md5_file_name(resource.irimage_file_name)
          irimage_file = "public/system/uploads/data/irimages/#{substation.id}-#{substation.name}/#{md5_irimage_name}"
          if File.exist?(irimage_file)
            irimage_md5 = Digest::MD5.hexdigest(File.read(irimage_file)) 
          end
        end
        unless resource.irp_file_name.blank?
          md5_irp_name = DetectionResource.md5_file_name(resource.irp_file_name)
          irp_file = "public/system/uploads/data/irps/#{substation.id}-#{substation.name}/#{md5_irp_name}"
          if File.exist?(irp_file)
            irp_md5 = Digest::MD5.hexdigest(File.read(irp_file)) 
          end
        end
        map = {}
        map.merge!(:irimage_md5 => irimage_md5) if irimage_md5
        map.merge!(:irp_md5 => irimage_md5) if irp_md5
        resource.update_attributes(map)
      end
    end
  end
end