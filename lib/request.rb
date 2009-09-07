class Request < ActiveRecord::Base
  # belongs_to :sender, :class_name => 'User' # TODO: this is also too specific (make sure to fix all dependent code)

  #validates_presence_of :sender_id # TODO: this shouldn't be required as it's too specific; requests can be made by a "system" as well
  validates_presence_of :recipient_email
  # validate :sender_is_not_recipient

  # TODO: move to observer?
  before_create :generate_token
  before_update :update_responded_at_if_responded
  after_update  :send_response_email_if_responded

  named_scope :with_no_response, :conditions => { :response => :none }
  
  def recipient
    @recipient ||= User.find_by_email(self.recipient_email)
  end

  def send_to_recipient
    raise "Can not call send_to_recipient on a request that has not been saved" if new_record?
    self.update_attribute(:sent_at, DateTime.now)

    # If class name is "AddClientRequest" then mailer action name is "request_to_add_client"
    # In addition, if the recipient is an existing user, we append "_internal" to the method
    deliver_request_method = "deliver_request_to_#{self.class.to_s.gsub(/Request$/,'').underscore}"
    # deliver_request_method = "#{deliver_request_method}_internal" if User.exists?(:email => self.recipient_email) # TODO: still too specific as it depends on Users

    # spawn do
      RequestMailer.send(deliver_request_method, self)
    # end

    return true
  end

  ###################################
  ## PROTECTED METHODS
  ###################################

  protected

  def before_create
    if Request.exists?(:sender_id => self.sender_id, :recipient_email => self.recipient_email, :type => self.type, :response => :none) # TODO: bad way to validate (unless there's an id for "systems")
      errors.add_to_base("There is already an outstanding request.")
      return false
    end
  end

  def after_create
    self.send_to_recipient
  end

  # def sender_is_not_recipient
  #   return if sender.nil?
  #   errors.add_to_base 'You cannot send a request to yourself.' if self.recipient_email == sender.email
  # end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def update_responded_at_if_responded
    self.responded_at = DateTime.now if changed.include?('response')
  end

  def send_response_email_if_responded
    if changed.include?('response') and self.response != :none
      # spawn do
        response_in_past_tense = case self.response
        when :deny then 'denied'
        else "#{self.response.to_s}ed"
        end
        deliver_request_response_method = "deliver_request_to_#{self.class.to_s.gsub(/Request$/,'').underscore}_#{response_in_past_tense}"
        RequestMailer.send(deliver_request_response_method, self)
      # end
    end
  end
  
  ###################################
  ## PRIVATE METHODS
  ###################################

  private

  # def self.request_types
  #   request_types = []
  #   Dir[RAILS_ROOT+'/app/models/requests/*_request.rb'].each do |file|
  #     request_types << File.basename(file, '.rb').camelize.constantize
  #   end
  #   request_types
  # end
  #   
  # request_types.each do |request_type|
  #   named_scope ('to_' + request_type.to_s.gsub(/Request$/, '').underscore).to_sym,
  #     :conditions => { :type => request_type.to_s }
  # end

end