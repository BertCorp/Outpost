class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer   :company_id,      null: false
      t.integer   :test_suite_id,   null: false
      t.datetime  :initiated_at
      t.integer   :initiated_by
      t.datetime  :started_at
      t.datetime  :completed_at
      t.integer   :monitored_by
      t.string    :status,          null: false, default: 'Queued'
      t.text      :summary
      
      t.timestamps
    end
  end
end
