class AdjustLengthOfTestDescriptions < ActiveRecord::Migration
  def up
      change_column :test_cases, :description, :text
  end
  def down
      # This might cause trouble if you have strings longer
      # than 255 characters.
      change_column :test_cases, :description, :string
  end
end
