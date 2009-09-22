require 'digest'

requests_path=File.join(RAILS_ROOT,'app','models','requests')
$: << requests_path

ActiveSupport::Dependencies.load_paths << requests_path
ActiveRecord::Base.observers << :request_observer