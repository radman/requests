class AddRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :sender_id
      t.string :recipient_email, :type, :token
      t.datetime :responded_at
      
      t.enum :response, :limit => [:none, :accept, :deny], :default => :none
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :requests
  end
end