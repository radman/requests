class RequestGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/requests'
      r.template 'request_subclass.rb.erb', "app/models/requests/#{singular_name}_request.rb"
      
      r.directory 'app/views/request_mailer'
      r.template 'mailer_view.erb', "app/views/request_mailer/#{singular_name}.erb"
    end
  end
end