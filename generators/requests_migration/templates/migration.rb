class AddCoolNotifications < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :sender_id
      t.string :recipient_email, :type, :token
      t.datetime :sent_at, :responded_at
      
      t.enum :response, :limit => [:none, :accept, :deny], :default => :none
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :requests
  end
end

create_table "requests", :force => true do |t|
  t.integer  "sender_id",                                                                      :null => false
  t.string   "recipient_email",                                                                :null => false
  t.string   "type",                                                                           :null => false
  t.string   "token",                                                                          :null => false
  t.datetime "created_at"
  t.datetime "updated_at"
  t.datetime "sent_at"
  t.datetime "responded_at"
  t.enum     "response",                 :limit => [:none, :accept, :deny], :default => :none
  t.integer  "coaching_relationship_id"
  t.text     "custom_message"
end