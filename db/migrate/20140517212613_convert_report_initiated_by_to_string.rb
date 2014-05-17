class ConvertReportInitiatedByToString < ActiveRecord::Migration
  def change
    change_column :reports, :initiated_by, :string
  end
end
