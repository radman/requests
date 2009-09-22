class Request < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User', 
    :primary_key => 'email', 
    :foreign_key => 'recipient_email'

  validates_presence_of :recipient_email
  validate_on_create :no_response, :is_unique
  validate_on_update :is_valid_response, :is_valid_change_of_response

  VALID_RESPONSES = ['accept', 'deny']
  
  
  ###################################
  ## HELPERS
  ###################################

  def accept
    update_attributes :response => 'accept'
  end
  
  def deny
    update_attributes :response => 'deny'
  end


  ###################################
  ## CUSTOM CALLBACKS
  ###################################
  
  # To be implemented by subclasses, if necessary
  def after_accept; end
  def after_deny; end
  

  ###################################
  ## USUAL CALLBACKS
  ###################################
  
  def before_create
    self.token = generate_token
  end
   
  def before_update
    self.responded_at = DateTime.now if changed.include?('response')
  end
  
  def after_update
    return unless changed.include?('response')
    
    case response
      when 'accept' then after_accept
      when 'deny' then after_deny
    end
  end
  

  private

  ###################################
  ## VALIDATION HELPERS
  ###################################
  
  def no_response
    errors.add_to_base 'Cannot respond to a request that has not been created.' if response != 'none'
  end
    
  def is_unique
    if Request.exists?(:sender_id => sender_id, :recipient_email => recipient_email, :type => type, :response => 'none')
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
    errors.add_to_base 'Cannot deny a request which has already been accepted.' if old_response == 'accept' and new_response == 'deny'
    errors.add_to_base 'Cannot accept a request which has already been denied.' if old_response == 'deny' and new_response == 'accept'
  end
  
  def self.validate_on_accept(*methods)
    validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == 'accept' 
    })  
  end

  def self.validate_on_deny(*methods)
    validate_on_update(methods, :if => Proc.new { |request| 
      request.changed.include?('response') && request.response == 'deny'
    })
  end
  
  ###################################
  ## OTHER HELPERS
  ###################################
  
  def generate_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
end