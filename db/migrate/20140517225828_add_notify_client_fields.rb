class AddNotifyClientFields < ActiveRecord::Migration
  def change
    add_column :test_suites, :start_notifying_at, :datetime
  end
end
