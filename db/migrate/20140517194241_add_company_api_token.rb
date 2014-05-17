class AddCompanyApiToken < ActiveRecord::Migration
  def change
    add_column :companies, :authentication_token, :string
  end
end
