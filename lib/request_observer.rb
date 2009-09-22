class RequestObserver < ActiveRecord::Observer  
  def before_create(request)
    request.token = generate_token
  end
  
  def before_update(request)
    request.changed.include?('response') && request.responded_at = DateTime.now
  end

  def after_update(request)
    request.changed.include?('response') && case request.response
      when 'accept' then request.after_accept
      when 'deny' then request.after_deny
    end
  end

  private
  
  def generate_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end