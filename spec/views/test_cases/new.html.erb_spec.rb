require 'spec_helper'

describe "test_cases/new" do
  before(:each) do
    assign(:test_case, stub_model(TestCase).as_new_record)
  end

  it "renders new test_case form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_cases_path, "post" do
    end
  end
end
