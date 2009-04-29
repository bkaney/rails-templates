# vermonster.com
# from Brian Kaney
#
# based on daring.rb from Peter Cooper

# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm -f public/javascripts/*"

# Download JQuery
if yes?("Do you want to install JQuery ? ")
  case ask("Which version  [2 or 3] ? ")
  when /2/
    run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.2.6.js  > public/javascripts/jquery.js"
  when /3/
    run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.1.js > public/javascripts/jquery.js"
  else
    puts "!!! not installing JQuery, didn't get a '2' or '3'"
  end
end

# reset.css
run "curl -L http://meyerweb.com/eric/tools/css/reset/reset.css > public/stylesheets/reset.css"

# Set up git repository
git :init
git :add => '.'
  
# Copy database.yml for distribution use
run "cp config/database.yml config/database.yml.example"
  
# Set up .gitignore files
run %{find . -type d -empty | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
config/database.yml
coverage/*
db/*.sqlite3
db/*.db
db/schema.rb
doc/app
log/*.log
tmp/**/*
END

# Install submoduled plugins
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git', :submodule => true
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true

# Install all gems
gem 'hpricot', :source => 'http://code.whytheluckystiff.net'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'ruby-openid', :lib => 'openid', :source => 'http://gems.github.com'
gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com'
gem 'rack', :source => 'http://gems.github.com'

rake("gems:install", :sudo => true)

# Set up sessions, RSpec, user model,
generate("authenticated", "user session")
generate("rspec")

# Set up session store initializer
initializer 'session_store.rb', <<-END
ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
END

capify!
#run "capify ."

# Initialize submodules
git :submodule => "init"

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "SUCCESS!"
