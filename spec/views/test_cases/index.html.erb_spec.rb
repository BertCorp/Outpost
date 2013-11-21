require 'spec_helper'

describe "test_cases/index" do
  before(:each) do
    assign(:test_cases, [
      stub_model(TestCase),
      stub_model(TestCase)
    ])
  end

  it "renders a list of test_cases" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
