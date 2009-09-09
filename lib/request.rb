class Request < ActiveRecord::Base
  validates_presence_of :recipient_email
  validate_on_create :is_unique_request
  
  def accept!
    update_attributes! :response => :accept
  end
  
  def deny!
    update_attributes! :response => :deny
  end

  def created; end
  def accepted; end
  def denied; end
  
  protected
  
  def is_unique_request
    if Request.exists?(:recipient_email => recipient_email, :type => type, :response => :none)
      errors.add_to_base("There is already an outstanding request.")
    end  
  end
end