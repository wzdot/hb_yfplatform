class PagesController < ApplicationController
  layout 'simple'

  def welcome
    render :layout => 'application'
  end

  def home
    render :layout => 'shoot-sequence'
  end

  def data_dictionary
    render :layout => 'data_dictionary'
  end

  def basic_data
    render :layout => 'basic_data'
  end

  def task
    render :layout => 'task'
  end

  def rule
    render :layout => 'rule'
  end

  def analyse
    render :layout => 'analyse'
  end

  def report
    render :layout => 'report'
  end

  def composite
    render :layout => 'composite'
  end
end
