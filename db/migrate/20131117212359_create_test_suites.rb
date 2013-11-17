class CreateTestSuites < ActiveRecord::Migration
  def change
    create_table :test_suites do |t|
      t.integer :company_id,      null: false
      t.string :title,            null: false, default: ''
      t.string :description,      null: false, default: ''
      t.string :setup_video_url

      t.timestamps
    end
  end
end
