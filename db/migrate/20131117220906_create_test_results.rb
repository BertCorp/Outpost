class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.integer   :report_id
      t.integer   :test_case_id
      t.datetime  :started_at
      t.datetime  :ended_at
      t.string    :status
      t.text      :summary
      
      t.timestamps
    end
  end
end
