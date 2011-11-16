class CreateRequestInvitations < ActiveRecord::Migration
  def change
    create_table :request_invitations do |t|
      t.string :name
      t.text :description
      t.string :email

      t.timestamps
    end
  end
end
