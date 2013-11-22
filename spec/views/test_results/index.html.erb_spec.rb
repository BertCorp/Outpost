require 'spec_helper'

describe "test_results/index" do
  before(:each) do
    assign(:test_results, [
      stub_model(TestResult),
      stub_model(TestResult)
    ])
  end

  it "renders a list of test_results" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
