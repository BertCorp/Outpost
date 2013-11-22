require 'spec_helper'

describe "test_results/edit" do
  before(:each) do
    @test_result = assign(:test_result, stub_model(TestResult))
  end

  it "renders the edit test_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_result_path(@test_result), "post" do
    end
  end
end
