require 'spec_helper'

describe "report_templates/edit" do
  before(:each) do
    @report_template = assign(:report_template, stub_model(ReportTemplate,
      :name => "MyString",
      :order_by1 => "MyString",
      :order_by2 => "MyString",
      :order_by3 => "MyString",
      :order_by4 => "MyString",
      :order_by5 => "MyString",
      :order_by6 => "MyString"
    ))
  end

  it "renders the edit report_template form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => report_templates_path(@report_template), :method => "post" do
      assert_select "input#report_template_name", :name => "report_template[name]"
      assert_select "input#report_template_order_by1", :name => "report_template[order_by1]"
      assert_select "input#report_template_order_by2", :name => "report_template[order_by2]"
      assert_select "input#report_template_order_by3", :name => "report_template[order_by3]"
      assert_select "input#report_template_order_by4", :name => "report_template[order_by4]"
      assert_select "input#report_template_order_by5", :name => "report_template[order_by5]"
      assert_select "input#report_template_order_by6", :name => "report_template[order_by6]"
    end
  end
end
