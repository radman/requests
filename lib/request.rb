# TODO: try to remove coupling to User class

class Request < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User', 
    :primary_key => 'email', 
    :foreign_key => 'recipient_email'

  validates_presence_of :recipient_email
  validate_on_create :no_response, :is_unique
  validate_on_update :is_valid_response, :is_valid_change_of_response

  VALID_RESPONSES = [:accept, :deny]
  
  def accept
    update_attributes :response => :accept
  end
  
  def deny
    update_attributes :response => :deny
  end

  # To be implemented by subclasses, if necessary
  def after_accept; end
  def after_deny; end
  
  private

  def no_response
    errors.add_to_base 'Cannot respond to a request that has not been created.' if response != :none
  end
    
  def is_unique
    if Request.exists?(:sender_id => sender_id, :recipient_email => recipient_email, :type => type, :response => :none)
      errors.add_to_base 'There is already an outstanding request.'
    end
  end
  
  def is_valid_response
    return unless changed.include?('response')
    errors.add_to_base "#{response} is not a valid response." unless VALID_RESPONSES.include?(response)
  end  

  def is_valid_change_of_response
    return unless changed.include?('response')
    old_response, new_response = changes['response']
    errors.add_to_base 'Cannot deny a request which has already been accepted.' if old_response == :accept and new_response == :deny
    errors.add_to_base 'Cannot accept a request which has already been denied.' if old_response == :deny and new_response == :accept
  end
  
  def self.validate_on_accept(*methods)
    validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == :accept 
    })  
  end

  def self.validate_on_deny(*methods)
    validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == :deny
    })
  end
end