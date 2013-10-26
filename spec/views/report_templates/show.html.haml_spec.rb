require 'spec_helper'

describe "report_templates/show" do
  before(:each) do
    @report_template = assign(:report_template, stub_model(ReportTemplate,
      :name => "Name",
      :order_by1 => "Order By1",
      :order_by2 => "Order By2",
      :order_by3 => "Order By3",
      :order_by4 => "Order By4",
      :order_by5 => "Order By5",
      :order_by6 => "Order By6"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Order By1/)
    rendered.should match(/Order By2/)
    rendered.should match(/Order By3/)
    rendered.should match(/Order By4/)
    rendered.should match(/Order By5/)
    rendered.should match(/Order By6/)
  end
end
