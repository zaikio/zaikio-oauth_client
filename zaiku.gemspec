$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "zaiku/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "zaiku"
  spec.version     = Zaiku::VERSION
  spec.authors     = ["Steffen Boller", "Christian Weyer"]
  spec.email       = ["sb@crispymtn.com", "cw@crispymtn.com"]
  spec.homepage    = "https://crispymtn.com"
  spec.summary     = "Zaiku Platform Connectivity"
  spec.description = "This gem provides a mountable Rails engine that provides single sign on, directory access and further ZAIKU platform connectivity."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/"
    spec.metadata["github_repo"] = "ssh://github.com/crispymtn/zaiku-gem"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.0"
  spec.add_dependency "oauth2"
  spec.add_dependency "rest_jeweler"
  spec.add_dependency 'jwt'

  spec.add_development_dependency "pg"
  spec.add_development_dependency "byebug"
end
