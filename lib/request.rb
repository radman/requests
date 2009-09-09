class Request < ActiveRecord::Base
  validates_presence_of :recipient_email
  validate_on_create :is_unique_request
    
  def accept!
    update_attributes! :response => :accept
  end
  
  def deny!
    update_attributes! :response => :deny
  end

  def after_create; end # this shouldn't be necessary
  def after_accept; end
  def after_deny; end
  
  protected

  def self.validate_on_accept(*methods)
    self.validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == :accept 
    })
  end
  
  def self.validate_on_deny(*methods)
    self.validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == :deny 
    })
  end
  
  def is_unique_request
    if Request.exists?(:recipient_email => recipient_email, :type => type, :response => :none)
      errors.add_to_base("There is already an outstanding request.")
    end  
  end
end