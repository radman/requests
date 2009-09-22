require 'digest'
require 'active_record'
require "#{File.expand_path(__FILE__).split('/')[0..-3].join('/')}/lib/request"

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => ':memory:')

Spec::Runner.configure do |config|
  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :users do |t|
        t.string :email
      end
      
      create_table :requests do |t|
        t.integer :sender_id
        t.string :recipient_email, :type, :token
        t.text :message
        t.datetime :responded_at
        
        t.string :response, :default => nil

        t.timestamps
      end      
    end    
  end
  
  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end    
  end
  
  config.before(:suite) do
    setup_db
    
    class RandomRequest < Request; end
    class DifferentRandomRequest < Request; end   
    class User < ActiveRecord::Base; end    
  end

  config.after(:suite) do
    teardown_db
  end
  
  config.before(:each) do
    Request.delete_all
    User.delete_all    
  end
end