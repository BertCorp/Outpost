class AddChatRoomToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :chatroom_url, :string
  end
end
