class RequestObserver < ActiveRecord::Observer
  def before_create(request)
    # TODO: somehow make into a validation
    if Request.exists?(:recipient_email => request.recipient_email, :type => request.type, :response => :none)
      request.errors.add_to_base("There is already an outstanding request.")
      return false
    end
    
    request.token = generate_token
  end

  def after_create(request)
    request.created
  end
  
  def before_update(request)
    if request.changed.include?('response')
      request.responded_at = DateTime.now
    end
  end
  
  def after_update(request)
    if request.changed.include?('response')
      request.accepted if request.response == :accept
    end
  end

  private
  
  def generate_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
end