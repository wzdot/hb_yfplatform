#coding: utf-8
require 'fileutils'

class BasicDataUploadifyController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:import]
	skip_before_filter :authenticate_user!, :only => [:import]

	def index
		# BasicDataImportJob::Handler.flush_all
		@options = BasicDataImportJob::Handler.fixed_columns
	end

	def import
		stream = params["Filedata"]
		suffix = stream.original_filename.end_with?('xls') ? 'xls' : 'xlsx'
		filename = "#{SecureRandom.hex}.#{suffix}"
		src = stream.tempfile.path
		FileUtils.mkdir_p( Rails.configuration.uploadify_tmp_dir )
		dst = "#{Rails.configuration.uploadify_tmp_dir}/#{filename}"
		FileUtils.mv(src, dst)
		if suffix == 'xls'
			s = Roo::Excel.new(dst)
		else
			s = Roo::Excelx.new(dst)
		end
		s.default_sheet = s.sheets.first
		columns = s.last_column
		cells = []
		1.upto(columns){|index| cells << {:value => index, :text => s.cell(1, index)}}
		render :json => {:filename => filename, :cells => cells}
	end

	def execute
		filename = params[:filename]
		link = params[:link]
		progress_id = filename[0, 32]
		Rails.cache.delete(progress_id)
		# BasicDataImportJob::Handler.flush_all
		BasicDataImportJob.perform_async(filename, link)
		render :json => {:status => 0}
	end

	def progress
		progress_id = params[:progress_id]
		ratio = Rails.cache.read(progress_id)
		if ratio.blank?
			ratio = 0
		end
		if ratio == 100
			BasicDataFlushJob.perform_async(progress_id)
		end
		render :json => {:ratio => ratio}
	end
end