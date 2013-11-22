require 'spec_helper'

describe "test_results/show" do
  before(:each) do
    @test_result = assign(:test_result, stub_model(TestResult))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
