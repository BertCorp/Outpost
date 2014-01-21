class CreateTestEnvironments < ActiveRecord::Migration
  def change
    create_table :test_environments do |t|
      t.integer   :company_id
      t.integer   :test_suite_id
      t.string    :name
      t.string    :url
      t.timestamps
    end

    create_table :test_cases_test_environments do |t|
      t.belongs_to  :test_case
      t.belongs_to  :test_environment
    end

    add_column :reports, :test_environment_id, :integer
    add_column :test_results, :test_environment_id, :integer
  end
end
