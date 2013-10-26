#coding: utf-8
class ReportTemplatesController < ApplicationController
  # GET /report_templates
  # GET /report_templates.json
  def index
    @report_templates = ReportTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_templates }
    end
  end

  # GET /report_templates/1
  # GET /report_templates/1.json
  def show
    @report_template = ReportTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_template }
    end
  end

  # GET /report_templates/new
  # GET /report_templates/new.json
  def new
    @report_template = ReportTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_template }
    end
  end

  # GET /report_templates/1/edit
  def edit
    @report_template = ReportTemplate.find(params[:id])
  end

  # POST /report_templates
  # POST /report_templates.json
  def create
    @report_template = ReportTemplate.new(params[:report_template])

    respond_to do |format|
      if @report_template.save
        format.html { redirect_to @report_template, notice: 'Report template was successfully created.' }
        format.json { render json: @report_template, status: :created, location: @report_template }
      else
        format.html { render action: "new" }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /report_templates/1
  # PUT /report_templates/1.json
  def update
    @report_template = ReportTemplate.find(params[:id])

    respond_to do |format|
      if @report_template.update_attributes(params[:report_template])
        format.html { redirect_to @report_template, notice: 'Report template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_templates/1
  # DELETE /report_templates/1.json
  def destroy
    @report_template = ReportTemplate.find(params[:id])
    @report_template.destroy

    respond_to do |format|
      format.html { redirect_to report_templates_url }
      format.json { head :no_content }
    end
  end

  def piece_of_paper
    id = params[:id]
    template = params[:template]
    detection = Detection.find_and_cache_composite_by_id(id)
    return if detection.nil?
    docx = Irp::Docx.new("config/#{template}.docx")
    docx.body do |processor|
      processor.replace_tag('zheng_wen_biao_ti', "#{detection.device_area_name}-#{detection.local_scene_name}#{detection.device_phasic}", :font_face => '楷体_GB2312', :font_size => 30)
      processor.replace_tag('bian_dian_zhan', detection.substation_name)
      processor.replace_tag('she_bei_lei_bie', detection.device_type_name)
      processor.replace_tag('she_bei_ming_cheng', detection.local_scene_name)
      processor.replace_tag('xiang_bie', detection.device_phasic)
      processor.replace_tag('yun_xing_dian_ya', detection.voltage_level_name)
      processor.replace_tag('pai_she_ri_qi', detection.detect_date.strftime('%Y-%m-%d'))
      processor.replace_tag('pai_she_shi_jian', detection.detect_time.strftime('%H:%M'))
      processor.replace_tag('bao_gao_ri_qi', Time.now.strftime('%Y-%m-%d'))
      resource = DetectionResource.find_and_cache_by_detection_id(id)
      path = resource.irimage.path
      if path.blank? || !File.exist?(path)
        processor.replace_tag("hong_wai_tu_xiang", '')
      else
        processor.replace_img_tag('hong_wai_tu_xiang', path)
      end
      if resource && (data = resource.irp_image_parse)
        processor.replace_tag('ce_shi_ju_li', data.distance)
        processor.replace_tag('huan_jing_wen_du', data.temperature)
        processor.replace_tag('huan_jing_shi_du', data.humidity)
        processor.replace_tag('fu_she_lv', data.radiance)
        data.unit_data.each_with_index do |(key, value), index|
          processor.replace_tag("fen_xi_dan_yuan_ge_#{index + 1}1", key)
          processor.replace_tag("zhi_dan_yuan_ge_#{index + 1}2", value)
        end
      end
    end
    send_data docx.generate_zip_in_memory, :filename => "report_#{Time.now.strftime("%Y-%m-%d_%H%M")}.docx"
  end
end
