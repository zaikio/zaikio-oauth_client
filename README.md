# ZAIKU Directory Gem

This Gem enables you to easily connect to the ZAIKU Directory and use the OAuth2 flow as well as query the API for information about the User and connected Organizations.

-- STILL A WORKING DRAFT --


## Installation

This gem is currently hosted privately in the **GitHub Package Registry**.

To fetch this gem from the GitHub Package Registry follow these steps:

1. You must use a personal access token with the `read:packages` and `write:packages` scopes to publish and delete public packages in the GitHub Package Registry with RubyGems. Your personal access token must also have the `repo` scope when the repository is private. For more information, see "[Creating a personal access token for the command line](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)."

2. Configure Bundler to use your token.

```bash
$ bundle config https://rubygems.pkg.github.com/crispymtn USERNAME:TOKEN
```

3. Include the gem in your Gemfile like this

```ruby
source "https://rubygems.pkg.github.com/crispymtn" do
  gem "zaiku"
end
```
4. To also make this work on Heroku or your CI App you can set an ENV variable like this:
```bash
BUNDLE_RUBYGEMS__PKG__GITHUB__COM=#Your-Token-Here#
```

## Setup & Configuration

1. Copy & run Migrations
```bash
rails zaiku_directory:install:migrations
rails db:migrate
```
This will create the tables:
+ `zaiku_people`
+ `zaiku_organizations`
+ `zaiku_organization_memberships`
+ `zaiku_access_tokens`


2. Mount routes
```ruby
mount Zaiku::Engine => "/zaiku"
```

3. Setup config in `config/initializers/zaiku_directory.rb`
```ruby
Zaiku.tap do |config|
  # App Settings
  config.client_id      = '36b25aa2-2547-4411-b8d0-bfc1f79f21e4'
  config.client_secret  = 'e415a98b72f0b48f554de75756f31780'
  config.directory_url  = 'http://directory.hc.test'
end
```


4. How to use the Zaiku models - tbd


## Use Engine in your application

### Redirect to OAuth

From any point in your application you can start using the ZAIKU Directory OAuth2 flow with

```ruby
redirect_to zaiku.new_session_path
```

This will redirect the user to the OAuth Authorize endpoint of the ZAIKU Directory `.../oauth/authorize` and include all necessary parameters like your client_id.

### Create or Update User

After the user logged in successfully at the ZAIKU Directory a redirect will happen back to your application to `.../zaiku/sessions/approve` (or whatever you mounted the Engine to) - including the Authorization Grant Code.

Exchanging the Code for an AccessToken and querying user data from the API will happen automatically in the `Zaiku::SessionsController`.




### Logging in the User

tbd

### Final Redirect

The `zaiku.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin: params[:origin]` which will then be used to redirect the user at the end of a completed & successful OAuth flow.



## Use of dummy app

You can use the included dummy app as a showcase for the workflow and to adjust your own application. To set up the dummy application properly, go into `test/dummy` and use [puma-dev](https://github.com/puma/puma-dev) like this:

```shell
puma-dev link -n 'zaiku-app'
```
This will make the dummy app available at: [http://zaiku-app.test](http://zaiku-app.test/)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/crispymtn/zaiku-gem.


### Release a new version into  GitHub Package Registry

Follow the setup instructions that can be found [in the GitHub docs](https://help.github.com/en/articles/configuring-rubygems-for-use-with-github-package-registry).

To push a new release:

- `gem build zaiku.gemspec`
- `gem push --key github --host https://rubygems.pkg.github.com/crispymtn zaiku-0.1.0.gem`
*Adjust the version accordingly.*


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
