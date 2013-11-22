require 'spec_helper'

describe "test_results/new" do
  before(:each) do
    assign(:test_result, stub_model(TestResult).as_new_record)
  end

  it "renders new test_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_results_path, "post" do
    end
  end
end
