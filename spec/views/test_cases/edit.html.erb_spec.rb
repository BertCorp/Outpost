require 'spec_helper'

describe "test_cases/edit" do
  before(:each) do
    @test_case = assign(:test_case, stub_model(TestCase))
  end

  it "renders the edit test_case form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_case_path(@test_case), "post" do
    end
  end
end
