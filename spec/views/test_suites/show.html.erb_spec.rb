require 'spec_helper'

describe "test_suites/show" do
  before(:each) do
    @test_suite = assign(:test_suite, stub_model(TestSuite))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
