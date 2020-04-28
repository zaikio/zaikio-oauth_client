# Zaikio::OAuthClient

This Gem enables you to easily connect to the Zaikio Directory and use the OAuth2 flow and easily lookup matching Access Tokens.


## Installation

This gem is a **Ruby Gem** and is hosted privately in the **GitHub Package Registry**.

To fetch it from the GitHub Package Registry follow these steps:

1. You must use a personal access token with the `read:packages` and `write:packages` scopes to publish and delete public packages in the GitHub Package Registry with RubyGems. Your personal access token must also have the `repo` scope when the repository is private. For more information, see "[Creating a personal access token for the command line](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)."

2. Set an ENV variable that will be used for both gem and npm. *This will also work on Heroku or your CI App if you set the ENV variable there.*
```bash
export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=#Your-Token-Here#
```

3. Add the following in your Gemfile

```ruby
source "https://rubygems.pkg.github.com/crispymtn" do
  gem "zaikio-oauth_client"
end
```
Then run `bundle install`.


## Setup & Configuration

### 1. Copy & run Migrations

```bash
rails zaikio_oauth_client:install:migrations
rails db:migrate
```

This will create the tables:
+ `zaikio_access_tokens`

### 2. Mount routes

```rb
mount Zaikio::OAuthClient::Engine => "/zaikio"
```

### 3. Configure Gem

```rb
# config/initializers/zaikio_oauth_client.rb
Zaikio::OAuthClient.configure do |config|
  config.environment = :test

  config.register_client :warehouse do |warehouse|
    warehouse.client_id       = "52022d7a-7ba2-41ed-8890-97d88e6472f6"
    warehouse.client_secret   = "ShiKTnHqEf3M8nyHQPyZgbz7"
    warehouse.default_scopes  = %w[directory.person.r]

    warehouse.register_organization_connection do |org|
      org.default_scopes = %w[directory.organization.r]
    end
  end

  config.register_client :warehouse_goods_call_of do |warehouse_goods_call_of|
    warehouse_goods_call_of.client_id       = "12345-7ba2-41ed-8890-97d88e6472f6"
    warehouse_goods_call_of.client_secret   = "secret"
    warehouse_goods_call_of.default_scopes  = %w[directory.person.r]

    warehouse_goods_call_of.register_organization_connection do |org|
      org.default_scopes = %w[directory.organization.r]
    end
  end

  config.around_auth do |access_token, block|
    Zaikio::Directory.with_token(access_token.token) do
      block.call(access_token)
    end
  end
end
```

## Usage

### OAuth Flow

From any point in your application you can start using the Zaikio Directory OAuth2 flow with

```rb
redirect_to zaikio_oauth_client.new_session_path
# or
redirect_to zaikio_oauth_client.new_session_path(client_name: 'my_other_client')
# or install as organization
redirect_to zaikio_oauth_client.new_connection_path(client_name: 'my_other_client')
```

This will redirect the user to the OAuth Authorize endpoint of the Zaikio Directory `.../oauth/authorize` and include all necessary parameters like your client_id.

#### Session handling

The Zaikio gem engine will set a cookie for the user after a successful OAuth flow: `cookies.encrypted[:zaikio_person_id]`.

If you are using for example `Zaikio::Directory::Models`, you can use this snippet to set the current user:

```ruby
Current.user ||= Zaikio::Directory::Models::Person.find_by(id: cookies.encrypted[:zaikio_person_id])
````

You can then use `Current.user` anywhere.

For **logout** use: `zaikio_oauth_client.session_path, method: :delete` or build your own controller for deleting the cookie.

#### Redirecting

The `zaikio_oauth_client.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin` which will then be used to redirect the user at the end of a completed & successful OAuth flow.

Additionally you can also specify your own redirect handlers in your `ApplicationController`:

```rb
class ApplicationController < ActionController::Base
  def after_approve_path_for(access_token, origin)
    cookies.encrypted[:zaikio_person_id] = access_token.bearer_id unless access_token.organization?

    # Sync data on login
    Zaikio::Directory.with_token(access_token.token) do
      access_token.bearer_klass.find_and_reload!(access_token.bearer_id, includes: :all)
    end

    origin || main_app.root_path
  end

  def after_destroy_path_for(access_token_id)
    cookies.delete :zaikio_person_id

    main_app.root_path
  end
end
```

#### Custom behavior

Since the built in `SessionsController` and `ConnectionsController` are inheriting from the main app's `ApplicationController` all behaviour will be added there, too. In some cases you might want to explicitly skip a `before_action` or add custom `before_action` callbacks.

You can achieve this by adding a custom controller name to your configuration:

```rb
# app/controllers/sessions_controller.rb
class SessionsController < Zaikio::OAuthClient::SessionsController
  skip_before_action :redirect_unless_authenticated
end

# config/initializers/zaikio_oauth_client.rb
Zaikio::OAuthClient.configure do |config|
  # ...
  config.sessions_controller_name = "sessions"
  # config.connections_controller_name = "connections"
  # ...
end
```

#### Testing

You can use our test helper to login different users:

```rb
# test_helper.rb
class ActiveSupport::TestCase
  # ...
  include Zaikio::OAuthClient::TestHelper
  # ...
end

# my_controller_test.rb
class MyControllerTest < ActionDispatch::IntegrationTest
  test "does request" do
    person = people(:my_person)
    logged_in_as(person)

    # ... make the request
  end
end
```

#### Authenticated requests

Now further requests to the Directory API or to other Zaikio APIs should be made. For this purpose the OAuthClient provides a helper method `with_auth` that automatically fetches an access token from the database, requests a refresh token or creates a new access token via client credentials flow.

```rb
Zaikio::OAuthClient.with_auth(bearer_type: "Organization", bearer_id: "fd61f5f5-038b-44cf-b554-dfe9555f1e29", scopes: %w[directory.organization.r directory.organization_members.r]) do |access_token|
  # call config.around_auth with given access token
end
```

## Use of dummy app

You can use the included dummy app as a showcase for the workflow and to adjust your own application. To set up the dummy application properly, go into `test/dummy` and use [puma-dev](https://github.com/puma/puma-dev) like this:

```shell
puma-dev link -n 'zaikio-oauth-client'
```
This will make the dummy app available at: [http://zaikio-oauth-client.test](http://zaikio-oauth-client.test/)

If you use the provided OAuth credentials from above and test this against the Sandbox, everything should work as the redirect URLs for [http://zaikio-oauth-client.test](http://zaikio-oauth-client.test/) are approved within the Sandbox.


## Contributing

**Make sure you have the dummy app running locally to validate your changes.**

Make your changes and adjust `version.rb`.

**To push a new release:**

- `gem build zaikio-oauth_client.gemspec`
- `gem push zaikio-oauth_client-0.1.0.gem`
*Adjust the version accordingly.*


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
