# -*- coding: utf-8 -*-
class DetectionResource < ActiveRecord::Base
  belongs_to :detection

  def self.default_missing_url
    "/assets/missing.jpg"
  end

  Paperclip::interpolates :custom_sub_dir do |attachment, style|
    detection = Detection.find_and_cache_composite_by_id(attachment.instance.detection_id)
    "#{detection.substation_id}-#{detection.substation_name}"
  end

  Paperclip::interpolates :md5_irimage_file_name do |attachment, style|
    irimage_file_name = attachment.instance.irimage_file_name
    DetectionResource.md5_file_name(irimage_file_name)
  end

  # 红外的分析结果文件
  has_attached_file :irjson,
                    :url => "/uploads/irjsons/:style/:basename.:extension",
                    :path => ":rails_root/public/uploads/irjsons/:style/:basename.:extension"
  validates_attachment_size :irjson, :in => 1..2.megabyte
  attr_protected :irjson_file_name, :irjson_content_type, :irjson_size
  
  # 普通格式的红外图片
  has_attached_file :irimage, {
    :url => "/system/uploads/data/irimages/:custom_sub_dir/:md5_irimage_file_name", 
    :path => ":rails_root/public/system/uploads/data/irimages/:custom_sub_dir/:md5_irimage_file_name"
  }
  validates_attachment_size :irimage, :in => 1..2.megabyte

  # 可见光图片
  has_attached_file :viimage, {
    :url => "/system/uploads/data/viimages/:custom_sub_dir/:basename.:extension", 
    :path => ":rails_root/public/system/uploads/data/viimages/:custom_sub_dir/:basename.:extension"
  }
  validates_attachment_size :viimage, :in => 1..2.megabyte

  # 原始格式的红外图片
  has_attached_file :irp, :styles => { :thumb => "160x120#" },  #original: 160x120 or 320x240 or 640x480
                    :whiny_thumbnails => true,
                    :url => "/uploads/irps/:style/:custom_sub_dir/:basename.:extension",
                    :path => ":rails_root/public/uploads/irps/:style/:custom_sub_dir/:basename.:extension"
  validates_attachment_size :irp, :in => 1..5.megabyte
  attr_accessible :irp_file_name, :irp_content_type, :irp_size

  has_attached_file :irv, :styles => { :thumb => "160x120#" },  #original: 160x120 or 320x240 or 640x480
                    :whiny_thumbnails => true,
                    :url => "/uploads/irvs/:style/:basename.:extension",
                    :path => ":rails_root/public/uploads/irvs/:style/:basename.:extension"
  validates_attachment_size :irv, :in => 1..5.megabyte
  attr_protected :irv_file_name, :irv_content_type, :irv_size



  # Map file extensions to mime types.                                                                                                                                                                                                
  # Thanks to bug in Flash 8 the content type is always set to application/octet-stream.                                                                                                                                              
  # From: http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload                                                                                                                                                    
  def swf_uploaded_data=( data )
    data.content_type = MIME::Types.type_for( data.original_filename )

    #logger "data content_type: #{data.content_type}"
    file_type = data.content_type[0].to_s
    self.DesStr = file_type
    if( file_type == 'image/jpeg' || file_type == 'image/jpg' )
      self.irimage = data
    elsif( file_type == 'application/json' )
      self.irjson = data
    end
  end

  def irp_image_parse
    return nil if params_json.blank?
    items = eval(params_json)
    hash = Hash[*items]
    irp = ParserIrp.new
    irp.distance = hash['距离']
    irp.temperature = hash['环境温度']
    irp.humidity = hash['相对湿度']
    irp.radiance = hash['辐射率']
    irp.unit_data = hash.select{|key, value| key =~ /\w{1}\d+/}
    irp
  end


  class ParserIrp
    attr_accessor :distance
    attr_accessor :temperature
    attr_accessor :humidity
    attr_accessor :radiance
    attr_accessor :unit_data
  end


  def self.find_and_cache_by_id(id)
    Rails.cache.fetch("resource_id_of_#{id}") do
      DetectionResource.find(id)
    end
  end

  def self.find_and_cache_by_detection_id(id)
    Rails.cache.fetch("resource_detection_id_of_#{id}") do
      DetectionResource.find_by_detection_id(id)
    end
  end

  def delete_cache
    Rails.cache.delete("resource_id_of_#{id}")
    Rails.cache.delete("resource_detection_id_of_#{detection_id}")
  end

  def self.md5_file_name(name)
    md5_file_name = name
    if name.bytesize > 255
      if data = /^(.+?)\.(jpg|irp|irp\.jpg)$/.match(name)
        file_name = Digest::MD5.hexdigest(data[1])
        extension = data[2]
        md5_file_name = "#{file_name}.#{extension}"
      end
    end
    md5_file_name
  end

  def self.rand_file_name
    "#{Time.now.strftime('%Y%m%d%H%M%S')}#{rand(100000..1000000)}"
  end
end