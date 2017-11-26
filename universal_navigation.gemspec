$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "universal_navigation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "universal_navigation"
  s.version     = UniversalNavigation::VERSION
  s.authors     = ["Andres Montano"]
  s.email       = ["amontano@virginia.edu"]
  s.homepage    = "http://subjects.kmaps.virginia.edu"
  s.summary     = "Universal Navigation allows for multiple Rails apps to use a single set of tabs to navigation between them.  The tabs will use either the app's home_path (the landing page of the app) or entity_path (a page dedicated to listing entities that are related to the previous page's entity), depending on the context."
  s.description = "Universal Navigation allows for multiple Rails apps to use a single set of tabs to navigation between them.  The tabs will use either the app's home_path (the landing page of the app) or entity_path (a page dedicated to listing entities that are related to the previous page's entity), depending on the context."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.add_dependency 'rails', '>= 4.0'
  # s.add_dependency "jquery-rails"
end
