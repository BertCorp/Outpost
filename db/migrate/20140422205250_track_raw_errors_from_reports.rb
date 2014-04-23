class TrackRawErrorsFromReports < ActiveRecord::Migration
  def change
    add_column :reports, :errors_raw, :text
  end
end
