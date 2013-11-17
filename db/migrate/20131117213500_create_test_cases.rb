class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.integer   :company_id,      null: false
      t.integer   :test_suite_id,   null: false
      t.string    :title,           null: false, default: ''
      t.string    :description,     null: false, default: ''
      # Awaiting Setup, Being Setup, Pending, Ready
      #t.string  :status,          null: false, default: 'Awaiting Setup' 
      t.datetime  :setup_started_at
      t.datetime  :setup_completed_at
      t.string    :pending_message
      
      t.timestamps
    end
  end
end
