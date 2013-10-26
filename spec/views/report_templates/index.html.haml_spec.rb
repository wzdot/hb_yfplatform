require 'spec_helper'

describe "report_templates/index" do
  before(:each) do
    assign(:report_templates, [
      stub_model(ReportTemplate,
        :name => "Name",
        :order_by1 => "Order By1",
        :order_by2 => "Order By2",
        :order_by3 => "Order By3",
        :order_by4 => "Order By4",
        :order_by5 => "Order By5",
        :order_by6 => "Order By6"
      ),
      stub_model(ReportTemplate,
        :name => "Name",
        :order_by1 => "Order By1",
        :order_by2 => "Order By2",
        :order_by3 => "Order By3",
        :order_by4 => "Order By4",
        :order_by5 => "Order By5",
        :order_by6 => "Order By6"
      )
    ])
  end

  it "renders a list of report_templates" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Order By1".to_s, :count => 2
    assert_select "tr>td", :text => "Order By2".to_s, :count => 2
    assert_select "tr>td", :text => "Order By3".to_s, :count => 2
    assert_select "tr>td", :text => "Order By4".to_s, :count => 2
    assert_select "tr>td", :text => "Order By5".to_s, :count => 2
    assert_select "tr>td", :text => "Order By6".to_s, :count => 2
  end
end
