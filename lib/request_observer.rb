class RequestObserver < ActiveRecord::Observer  
  def before_create(request)  
    request.token = generate_token
  end

  def after_create(request)
    request.created
  end
  
  def before_update(request)
    request.responded_at = DateTime.now if request.changed.include?('response')
  end
  
  def after_update(request)
    request.changed.include?('response') && case request.response
      when :accept then request.accepted
      when :deny then request.denied
    end
  end

  private
  
  def generate_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end