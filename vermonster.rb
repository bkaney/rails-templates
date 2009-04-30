# vermonster.rb from Brian Kaney
#
# based on daring.rb from Peter Cooper
#
# Added ability to specify which version of jquery and a basic layout template.


# -----------------
# Delete unnecessary files

run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm -f public/javascripts/*"


# -----------------
# Download JQuery and reset

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

run "curl -L http://meyerweb.com/eric/tools/css/reset/reset.css > public/stylesheets/reset.css"

# Set up git repository
  
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

git :init
git :add => '.'

# Install submoduled plugins
plugin 'rspec', 
  :git => 'git://github.com/dchelimsky/rspec.git', 
  :submodule => true

plugin 'rspec-rails', 
  :git => 'git://github.com/dchelimsky/rspec-rails.git', 
  :submodule => true

plugin 'cucumber', 
  :git => 'git://github.com/aslakhellesoy/cucumber.git', 
  :submodule => true

plugin 'webrat', 
  :git => 'git://github.com/brynary/webrat.git', 
  :submodule => true

plugin 'asset_packager',
  :git => 'git://github.com/sbecker/asset_packager.git', 
  :submodule => true

plugin 'open_id_authentication', 
  :git => 'git://github.com/rails/open_id_authentication.git',
  :submodule => true

plugin 'restful-authentication', 
  :git => 'git://github.com/technoweenie/restful-authentication.git', 
  :submodule => true

plugin 'exception_notifier', 
  :git => 'git://github.com/rails/exception_notification.git', 
  :submodule => true

# Install all gems
gem 'hpricot',  :source => 'http://code.whytheluckystiff.net'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'ruby-openid', :lib => 'openid', :source => 'http://gems.github.com'
gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com'
gem 'rack', :source => 'http://gems.github.com'

rake("gems:install", :sudo => true)

# Set up authentication, sessions, rspec and cucumber
generate("authenticated", "user session")
generate("rspec")
generate("cucumber")


# -----------------
# Files

file 'app/views/layouts/_flashes.html.erb', 
%q{<div id="flash">
  <% flash.each do |key, value| -%>
    <div class="flash_<%= key %>"><%=h value %></div>
  <% end -%>
</div><!-- #flash -->
}

file 'app/views/layouts/application.html.erb', 
%q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <title>PROJECT NAME</title>
    <%= stylesheet_link_merged :base %>
    <%= javascript_include_merged :early %>
  </head>
  <body>
    <div id="container">

      <div id="header">
      </div><!-- #header -->

      <div id="content">
        <%= render :partial => 'layouts/flashes' -%>
        <%= yield %>
      </div><!-- #content -->

      <div id="footer">
      </div><!-- #footer -->

    </div><!-- #container -->

    <%= javascript_include_merged :late %>

  </body>
</html>
}

file 'public/stylesheets/main.css', 
%q{/**
 * main application stylesheet
 */
}

file 'config/asset_packager.yml', 
%q{--- 
javascripts: 
- early:
  - jquery
  - application
- late: []
stylesheets: 
- base:
  - reset
  - main
}

# -----------------
# Initializers

initializer 'asset_packager.rb', 
%q{# Merge CSS and JS in these environments
Synthesis::AssetPackage.merge_environments = ['production', 'staging']
}

initializer 'patches.rb', "# This is where we put our patches"

initializer 'session_store.rb',
%q{ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
}


capify!

# -----------------
# Setup SCM

git :add => '.'
git :submodule => "init"
git :commit => "-a -m 'Genesis!'"


# Success!
puts "SUCCESS!"
