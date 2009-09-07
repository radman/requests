class RequestMailerGenerator < Rails::Generator::Base
  
  def manifest
    record do |r|
      r.template 'mailer.rb.erb', 'app/models/request_mailer.rb'
    end
  end
  
end