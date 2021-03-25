$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "zaikio/oauth_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "zaikio-oauth_client"
  spec.version     = Zaikio::OAuthClient::VERSION
  spec.authors     = ["Zaikio GmbH"]
  spec.email       = ["sb@zaikio.com", "cw@zaikio.com", "mp@zaikio.com", "js@zaikio.com"]
  spec.homepage    = "https://github.com/zaikio/zaikio-oauth_client"
  spec.summary     = "Zaikio Platform Connectivity"
  spec.description = "This gem provides a mountable Rails engine that provides single sign on, directory access and further Zaikio platform connectivity."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  if spec.respond_to?(:metadata)
    spec.metadata["changelog_uri"] = "https://github.com/zaikio/zaikio-oauth_client/blob/master/CHANGELOG.md"
  end

  spec.add_dependency "actionpack", ">= 5.0.0"
  spec.add_dependency "activerecord", ">= 5.0.0"
  spec.add_dependency "activesupport", ">= 5.0.0"
  spec.add_dependency "railties", ">= 5.0.0"
  spec.add_dependency "oauth2"
  spec.add_dependency "zaikio-jwt_auth", ">= 0.2.1", "< 0.5.0"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "byebug"
end
