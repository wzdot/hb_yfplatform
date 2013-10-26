require "spec_helper"

describe ReportTemplatesController do
  describe "routing" do

    it "routes to #index" do
      get("/report_templates").should route_to("report_templates#index")
    end

    it "routes to #new" do
      get("/report_templates/new").should route_to("report_templates#new")
    end

    it "routes to #show" do
      get("/report_templates/1").should route_to("report_templates#show", :id => "1")
    end

    it "routes to #edit" do
      get("/report_templates/1/edit").should route_to("report_templates#edit", :id => "1")
    end

    it "routes to #create" do
      post("/report_templates").should route_to("report_templates#create")
    end

    it "routes to #update" do
      put("/report_templates/1").should route_to("report_templates#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/report_templates/1").should route_to("report_templates#destroy", :id => "1")
    end

  end
end
