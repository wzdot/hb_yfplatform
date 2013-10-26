# -*- coding: utf-8 -*-
module ApplicationHelper
  # https://x.com/y/1?page=1
  # + current_url( :page => 3 )
  # = https://x.com/y/1?page=3
  def current_url(overwrite={})
    url_for :only_path => false, :params => params.merge(overwrite)
  end

  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    # args.collect!{|arg| "ie6/#{arg}"} if is_ie6?
    content_for(:stylesheet) { stylesheet_link_tag(*args) }
  end

  def stylesheet_last(*args)
    # args.collect!{|arg| "ie6/#{arg}"} if is_ie6?
    content_for(:stylesheet_last) { stylesheet_link_tag(*args) }
  end

  #在子页面中使用，令得加入的js文件能放在文档最后
  def javascript_last(*args)
    # args.collect!{|arg| "ie6/#{arg}"} if is_ie6?
    content_for(:javascript_last) { javascript_include_tag(*args) }
  end

  def javascript(*args)
    # args.collect!{|arg| "ie6/#{arg}"} if is_ie6?
    content_for(:javascript) { javascript_include_tag(*args) }
  end

  def iframe( sContent )
    content_for(:iframe) { sContent }
  end

  def active_scaffold_fragment_key
    options = ["active_scaffold_fragment"]
    options << "#{controller_name}"
    options << @page.number if @page
    options << search_params unless search_params.blank?
    options.join('_').downcase
  end
end
