class Request < ActiveRecord::Base
  validates_presence_of :recipient_email
  validate_on_create :is_unique_request
  
  def accept!
    self.response = :accept
    self.save!
  end

  def created
    raise "Request.created must be implemented by all subclasses of Request"
  end
  
  def accepted
    raise "Request.accepted must be implemented by all subclasses of Request"
  end
  
  protected
  
  def is_unique_request
    if Request.exists?(:recipient_email => recipient_email, :type => type, :response => :none)
      errors.add_to_base("There is already an outstanding request.")
    end  
  end
end