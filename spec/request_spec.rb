require "#{File.expand_path(__FILE__).split('/')[0..-3].join('/')}/spec/spec_helper"

describe Request do
  
  describe "on creation" do
    it "should be invalid if a response other than nil is specified" do
      @request = RandomRequest.new(:recipient_email => 'coolguy@noomiixx.com', :response => 'accept')
      @request.should_not be_valid
    end
    
    it "should be invalid if the recipient's email is not specified" do
      @request = RandomRequest.new
      @request.should_not be_valid
    end
    
    it "should have a recipient that references a user, if a user with that email exists" do
      radu = User.create!(:email => 'radu@noomiixx.com')
      @request = RandomRequest.create!(:recipient_email => 'radu@noomiixx.com')
      @request.recipient.id.should == radu.id
    end    
  end
  
  describe "after being created" do
    before(:each) do
      @request = RandomRequest.create!(:recipient_email => 'coolguy@noomiixx.com')
    end
    
    it "should have response set to nil" do
      @request.response.should be_nil
    end
  
    it "should have responded_at set to nil" do
      @request.responded_at.should be_nil
    end
  
    it "should have a token" do
      @request.token.should_not be_nil
    end
    
    it "can be accepted" do
      @request.response = 'accept'
      @request.should be_valid
    end
    
    it "can be denied" do
      @request.response = 'deny'
      @request.should be_valid
    end
    
    it "can only be accepted or denied" do
      @request.response = 'random_response'
      @request.should_not be_valid    
    end  
  
    it "should not update responded_at if response field does not change" do
      @request.recipient_email = "raduasdf@noomiixxx.com"
      @request.save!
      @request.responded_at.should be_nil
    end
  end
  
  describe "after being accepted" do
    before(:each) do
      @request = RandomRequest.create!(:recipient_email => 'coolguy@noomiixx.com')
      @request.response = 'accept'
      @request.save!
    end
  
    it "should update responded_at" do
      @request.responded_at.should_not be_nil
    end
  
    it "cannot be denied" do
      @request.response = 'deny'
      @request.should_not be_valid
    end
  
    it "cannot have its response set back to nil" do
      @request.response = nil
      @request.should_not be_valid
    end 
  end
  
  describe "after being denied" do
    before(:each) do
      @request = RandomRequest.create!(:recipient_email => 'coolguy@noomiixx.com')
      @request.response = 'deny'
      @request.save!
    end
  
    it "should update responded_at" do
      @request.responded_at.should_not be_nil
    end
  
    it "cannot be accepted" do
      @request.response = 'accept'
      @request.should_not be_valid
    end
  
    it "cannot have its response set back to nil" do
      @request.response = nil
      @request.should_not be_valid
    end 
  end 
  
  describe "duplicate requests" do
    before(:each) do
      @sender = User.create!(:email => 'thesender@noomiixx.com')
      @request = RandomRequest.create!(:sender => @sender, :recipient_email => 'coolguy@noomiixx.com')
    end
    
    it "should be invalid if it has no response and has the same type, sender and recipient_email as another unresponded request" do
      @duplicate_request = RandomRequest.new(:sender => @sender, :recipient_email => 'coolguy@noomiixx.com')
      @duplicate_request.should_not be_valid
    end
  
    it "should be valid if it has no response and has the same type, sender as another unresponded request, but different recipient_email" do
      @duplicate_request = RandomRequest.new(:sender => @sender, :recipient_email => 'awesomedude@noomiixx.com')
      @duplicate_request.should be_valid
    end
      
    it "should be valid if it has no response and has the same type, recipient_email as another unresponded request, but different sender" do
      different_sender = User.create!(:email => 'coolersender@noomiixx.com')
      @duplicate_request = RandomRequest.new(:sender => different_sender, :recipient_email => 'coolguy@noomiixx.com')
      @duplicate_request.should be_valid
    end
      
    it "should be valid if it has no response and has the same sender, recipient_email as another unresponded request, but different type" do
      @duplicate_request = DifferentRandomRequest.new(:sender => @sender, :recipient_email => 'coolguy@noomiixx.com')
      @duplicate_request.should be_valid
    end
      
    it "should be valid if it has no response and has the same sender, recipient_email, type as another request which has already been responded to" do
      @request.response = 'accept'
      @request.save!
      
      @duplicate_request = RandomRequest.new(:sender => @sender, :recipient_email => 'coolguy@noomiixx.com')
      @duplicate_request.should be_valid
    end    
  end
  
  describe "callbacks" do
    before(:each) do
      @request = RandomRequest.create!(:recipient_email => 'coolguy@noomiixx.com')
    end
    
    it "should invoke after_accept callback on being accepted" do
      @request.response = 'accept'
      @request.should_receive(:after_accept)
      @request.save!
    end
    
    it "should invoke after_deny callback on being denied" do
      @request.response = 'deny'
      @request.should_receive(:after_deny)
      @request.save!
    end
    
    it "should not invoke after_deny callback on being accepted" do
      @request.response = 'accept'
      @request.should_not_receive(:after_deny)
      @request.save!
    end    
    
    it "should not invoke after_accept callback on being denied" do
      @request.response = 'deny'
      @request.should_not_receive(:after_accept)
      @request.save!
    end
    
    it "should not invoke after_deny callback if response doesn't change" do
      @request.response = 'deny'
      @request.save!
      @request.recipient_email = "radu@noomiixx.com"
      @request.should_not_receive(:after_deny)
      @request.save!
    end    
    
    it "should not invoke after_accept if response doesn't change" do
      @request.response = 'accept'
      @request.save!
      @request.recipient_email = "radu@noomiixx.com"
      @request.should_not_receive(:after_accept)
      @request.save!
    end
  end
  
  describe "when validation callbacks are defined" do
    before(:all) do
      class ValidatedRequest < Request
        validate_on_accept :method1, :method2
        validate_on_deny :method1, :method3
      
        private
      
        def method1; end
        def method2; end
        def method3; end      
      end
    end
       
    before(:each) do
      @request = ValidatedRequest.create!(:recipient_email => 'coolguy@noomiixx.com')
    end
  
    it "should invoke validate_on_accept methods on being accepted" do
      @request.response = 'accept'
      @request.should_receive(:method1)
      @request.should_receive(:method2)
      @request.save!
    end
    
    it "should invoke validate_on_deny methods on being denied" do
      @request.response = 'deny'
      @request.should_receive(:method1)
      @request.should_receive(:method3)
      @request.save!
    end
  end
  
  describe "accept method" do
    it "should set the response to 'accept'" do
      @request = RandomRequest.create!(:recipient_email => 'radu@noomiixx.com')
      @request.accept
      @request.response.should == 'accept'
    end
    
    it "should soft-save the request" do
      @request = RandomRequest.create!(:recipient_email => 'radu@noomiixx.com')
      @request.should_receive(:save)
      @request.accept      
    end
  end
  
  describe "deny method" do
    it "should set the response to 'deny'" do
      @request = RandomRequest.create!(:recipient_email => 'radu@noomiixx.com')
      @request.deny
      @request.response.should == 'deny'
    end
    
    it "should soft-save the request" do
      @request = RandomRequest.create!(:recipient_email => 'radu@noomiixx.com')
      @request.should_receive(:save)
      @request.deny
    end
  end  

end