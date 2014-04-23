class TrackRawErrorsFromTestResults < ActiveRecord::Migration
  def change
    add_column :test_results, :errors_raw, :text
  end
end
