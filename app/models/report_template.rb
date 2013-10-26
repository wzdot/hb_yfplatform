# -*- coding: utf-8 -*-
class ReportTemplate < ActiveRecord::Base
  attr_accessible :name, :order_by1, :order_by2, :order_by3, :order_by4, :order_by5, :order_by6

  has_attached_file :cover, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  attr_protected :cover_file_name, :cover_content_type, :cover_size

  has_attached_file :preface, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  has_attached_file :contents, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  has_attached_file :page_header, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  has_attached_file :page_footer, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  has_attached_file :detail, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
  has_attached_file :back_cover, :url => "/uploads/report_templates/:style/:basename.:extension", :path => ":rails_root/public/uploads/report_templates/:style/:basename.:extension"
end
