
# Zaikio Directory Gem

This Gem enables you to easily connect to the Zaikio Directory and use the OAuth2 flow as well as query the API for information about the User and connected Organizations.

-- STILL A WORKING DRAFT --


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

1. Copy & run Migrations
```bash
rails zaikio_oauth_client:install:migrations
rails db:migrate
```
This will create the tables:
+ `zaikio_people`
+ `zaikio_organizations`
+ `zaikio_organization_memberships`
+ `zaikio_access_tokens`
+ `zaikio_sites`

2. Mount routes
```ruby
mount Zaikio::OAuthClient::Engine => "/zaikio"
```

3. Setup config in `config/initializers/zaikio_directory.rb`
```ruby
Zaikio::OAuthClient.tap do |config|
  # App Settings
  config.client_id      = '52022d7a-7ba2-41ed-8890-97d88e6472f6'
  config.client_secret  = 'ShiKTnHqEf3M8nyHQPyZgbz7'
  config.directory_url  = 'https://directory.sandbox.zaikio.com'
end
```

## Use the Rails Engine in your application

### Models and relations

The engine provides you with the following models to use in your application:
+ `Zaikio::Person`
+ `Zaikio::Organization`
+ `Zaikio::OrganizationMembership`
+ `Zaikio::AccessToken` (you should not require to use this one)
+ `Zaikio::Site`

A `Zaikio::Person` has many `:memberships` and `:organizations`.
A `Zaikio::Organization` has many `:memberships` and `:members` and and `:sites`.

#### Add references between Zaikio models and your models

If you want to establish a reference between your own models and the Zaikio models:

```ruby
# add migration
def change
  add_reference :items, :person, type: :uuid, foreign_key: { to_table: :zaikio_people }
end

# in your item.rb model
belongs_to :person, class_name: 'Zaikio::Person'
```

Of course you could also reference to `zaikio_organizations`.

#### Add logic to the Zaikio models

You can easily make your own model and let it inherit from one of the Zaikio models do add more behaviour and relations:

```ruby
# in your customer.rb
class Customer < Zaikio::Organization
  # Associations
  has_many :vehicles
  has_many :facilities

  def your_own_methods
  end
end
```

### OAuth Flow

From any point in your application you can start using the Zaikio Directory OAuth2 flow with

```ruby
redirect_to zaikio_oauth_client.new_session_path
```

This will redirect the user to the OAuth Authorize endpoint of the Zaikio Directory `.../oauth/authorize` and include all necessary parameters like your client_id.

#### Create or update Person and Organization data

After the user logged in successfully at the Zaikio Directory a redirect will happen back to your application to `.../zaikio/sessions/approve` (or whatever you mounted the Engine to) - including the Authorization Grant Code.

Exchanging the Code for an AccessToken and querying user data from the API will happen automatically in the `Zaikio::SessionsController`.

All Zaikio models (`Zaikio::Person, Zaikio::Organization, Zaikio::OrganizationMembership`) in relation to the signed in user will automatically be created or updated (depending on if already present in your database).

#### Session handling

The Zaikio gem engine will set a cookie for the user after a successful OAuth flow: `cookies.encrypted[:zaikio_person_id]`.

In your controllers include the concern `Zaikio::CookieBasedAuthentication` which will set:
```ruby
Current.user ||= Person.find_by(id: cookies.encrypted[:zaikio_person_id])
````

You can then use `Current.user` anywhere.

As an alternative build your own concern and use the `zaikio_person_id` from the encrypted cookie within your application as you like.


For **logout** use: `zaikio_oauth_client.session_path, method: :delete` or build your own controller for deleting the cookie.

#### Redirecting

The `zaikio_oauth_client.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin` which will then be used to redirect the user at the end of a completed & successful OAuth flow.


## Use Sandbox for testing

With the above described credentials you can connect right away to our Sandbox environment to get access to the demo app with demo users.

The UUID of people and organizations within the Sandbox are the same as within the fixtures of this gem (see `zaikio_people.yml`and `zaikio_organizations.yml`).

### OAuth workflow testing

This gem provides a test which will initiate th OAuth process, open the Sandbox Directory within the Chrome browser, enter the credentials of a demo user and check if will be successfully redirected.

To run the test use
```bash
rails app:test:system
```


#### Prerequisites

Make sure you have used `bundle install` for the `selenium-webdriver` gem and make sure chromedriver is working:

```bash
chromedriver -v
```

You might encounter some version issues with Rbenv and Chromedriver, to resolve [follow these steps](https://medium.com/fusionqa/issues-with-rbenv-and-chromedriver-990bb14aa57a).

#### Manual Testing

To log in by yourself and test the process manually, use the demo person with the credentials you can find in `test/system/zaikio/oauth_client/sessions_test.rb`.


## Use of dummy app

You can use the included dummy app as a showcase for the workflow and to adjust your own application. To set up the dummy application properly, go into `test/dummy` and use [puma-dev](https://github.com/puma/puma-dev) like this:

```shell
puma-dev link -n 'zaikio-oauth-client'
```
This will make the dummy app available at: [http://zaikio-oauth-client.test](http://zaikio-oauth-client.test/)

If you use the provided OAuth credentials from above and test this against the Sandbox, everything should work as the redirect URLs for [http://zaikio-oauth-client.test](http://zaikio-oauth-client.test/) are approved within the Sandbox.


## Contributing

**Make sure you have the dummy app running locally to validate your changes.**

Follow the setup instructions for gem credentials and bundler that can be found [in the GitHub docs](https://help.github.com/en/articles/configuring-rubygems-for-use-with-github-package-registry#authenticating-to-github-package-registry).

Make your changes and adjust `version.rb`.

**To push a new release:**

- `gem build zaikio-oauth_client.gemspec`
- `gem push --key github --host https://rubygems.pkg.github.com/crispymtn zaikio-oauth_client-0.1.0.gem`
*Adjust the version accordingly.*


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
