requests_path=File.join(RAILS_ROOT,'app','models','requests')
$LOAD_PATH << requests_path
ActiveSupport::Dependencies.load_paths << requests_path