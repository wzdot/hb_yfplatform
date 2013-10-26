#coding: utf-8
require 'fileutils'
class ShootDataUploadifyController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:import]
	skip_before_filter :authenticate_user!, :only => [:import]

	def index
		# ShootDataImportJob::Handler.flush_all
		# @auth_token = current_user.authentication_token
		# @auth_token = current_user.reset_authentication_token! if @auth_token.nil?
		# ShootDataImportJob::Handler.flush_all
	end

	def import
		stream = params["Filedata"]
		filename = stream.original_filename
		tempfile = stream.tempfile.path.sub('/tmp/', '')
		if /^(\d)(\d{4})(\d{4})(\d{6})-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)-(.*?)\.(jpg|irp|irp\.jpg)$/.match(filename) 
			src = "#{Rails.configuration.uploadify_tmp_dir}/#{tempfile}"
			FileUtils.mv(stream.tempfile.path, src)
			ShootDataImportJob.perform_async(filename, src)
			render :json => {:valid => true, :filename => filename}
		else
			FileUtils.rm_f(stream.tempfile.path)
			render :json => {:valid => false,:filename => filename}
		end
	end
end