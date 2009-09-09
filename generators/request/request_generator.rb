class RequestGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/requests'
      r.template 'request_subclass.rb.erb', "app/models/requests/#{singular_name}_request.rb"
    end
  end
end