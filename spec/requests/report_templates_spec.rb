#coding: utf-8
require 'spec_helper'
require_relative 'request_helpers'

include RequestHelpers

describe "ReportTemplates" do
	let(:authed_user) { create_logged_in_user }
  describe "GET /report_templates" do
    it "works! (now write some real specs)" do
    	authed_user
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get report_templates_path
      response.status.should be(200)
    end
  end
end
