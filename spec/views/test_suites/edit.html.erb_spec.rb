require 'spec_helper'

describe "test_suites/edit" do
  before(:each) do
    @test_suite = assign(:test_suite, stub_model(TestSuite))
  end

  it "renders the edit test_suite form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_suite_path(@test_suite), "post" do
    end
  end
end
