require 'spec_helper'

describe "test_suites/index" do
  before(:each) do
    assign(:test_suites, [
      stub_model(TestSuite),
      stub_model(TestSuite)
    ])
  end

  it "renders a list of test_suites" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
