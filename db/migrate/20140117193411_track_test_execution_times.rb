class TrackTestExecutionTimes < ActiveRecord::Migration
  def change
    add_column :test_results, :execution_time, :string
  end
end
