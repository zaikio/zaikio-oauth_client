# Zaikio::OAuthClient

This Gem enables you to easily connect to the Zaikio Directory and use the OAuth2 flow and easily lookup matching Access Tokens.


## Installation

Simply add the following in your Gemfile:

```ruby
gem "zaikio-oauth_client"
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

Add this to `config/routes.rb`:

```rb
mount Zaikio::OAuthClient::Engine => "/zaikio"
```

### 3. Configure Gem

```rb
# config/initializers/zaikio_oauth_client.rb
Zaikio::OAuthClient.configure do |config|
  config.environment = :sandbox

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
    Zaikio::Hub.with_token(access_token.token) do
      block.call(access_token)
    end
  end
end
```


### 4. Clean up outdated access tokens (recommended)

To avoid keeping all expired oath and refresh tokens in your database, we recommend to implement their scheduled deletion. We recommend therefore to use a schedule gems such as [sidekiq](https://github.com/mperham/sidekiq) and [sidekiq-scheduler](https://github.com/moove-it/sidekiq-scheduler).

Simply add the following to your Gemfile:

```rb
gem "sidekiq"
gem "sidekiq-scheduler"
```
Then run `bundle install`.

Configure sidekiq scheduler in `config/sidekiq.yml`:
```yaml
:schedule:
  cleanup_acces_tokens_job:
    cron: '0 3 * * *'               # This will delete all expired tokens every day at 3am.
    class: 'Zaikio::CleanupAccessTokensJob'
```


## Usage

### OAuth Flow

From any point in your application you can start using the Zaikio Hub OAuth2 flow with

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

If you are using for example `Zaikio::Hub::Models`, you can use this snippet to set the current user:

```ruby
Current.user ||= Zaikio::Hub::Models::Person.find_by(id: cookies.encrypted[:zaikio_person_id])
````

You can then use `Current.user` anywhere.

For **logout** use: `zaikio_oauth_client.session_path, method: :delete` or build your own controller for deleting the cookie.

#### Multiple clients

When performing requests against directory APIs, it is important to always provide the correct client in order to use the client credentials flow correctly. Otherwise always the first client will be used. It is recommended to specify an `around_action`:

```rb
class ApplicationController < ActionController::Base
  around_action :with_client

  private

  def with_client
    Zaikio::OAuthClient.with_client Current.client_name do
      yield
    end
  end
end
```

#### Redirecting

The `zaikio_oauth_client.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin` which will then be used to redirect the user at the end of a completed & successful OAuth flow.

Additionally you can also specify your own redirect handlers in your `ApplicationController`:

```rb
class ApplicationController < ActionController::Base
  def after_approve_path_for(access_token, origin)
    cookies.encrypted[:zaikio_person_id] = access_token.bearer_id unless access_token.organization?

    # Sync data on login
    Zaikio::Hub.with_token(access_token.token) do
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

- Make your changes and submit a pull request for them
- Make sure to update `CHANGELOG.md`

To release a new version of the gem:
- Update the version in `lib/zaikio/oauth_client/version.rb`
- Update `CHANGELOG.md` to include the new version and its release date
- Commit and push your changes
- Create a [new release on GitHub](https://github.com/zaikio/zaikio-directory-models/releases/new)
- CircleCI will build the Gem package and push it Rubygems for you

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
