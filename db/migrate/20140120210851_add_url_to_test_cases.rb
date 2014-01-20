class AddUrlToTestCases < ActiveRecord::Migration
  def change
    add_column :test_cases, :url, :string
  end
end
