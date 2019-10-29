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
rails zaiku:install:migrations
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
  config.client_id      = '52022d7a-7ba2-41ed-8890-97d88e6472f6'
  config.client_secret  = 'ShiKTnHqEf3M8nyHQPyZgbz7'
  config.directory_url  = 'https://directory.sandbox.zaiku.cloud'
end
```

## Use the Engine in your application

### Models and relations

The engine provides you with the following models to use in your application:
+ `Zaiku::Person`
+ `Zaiku::Organization`
+ `Zaiku::OrganizationMembership`
+ `Zaiku::AccessToken` (you should not require to use this one)

A `Zaiku::Person` has many `:memberships` and `:organizations`.
A `Zaiku::Organization` has many `:memberships` and `:members`.

#### Add references between Zaiku models and your models

If you want to establish a reference between your own models and the Zaiku models:

```ruby
# add migration
def change
  add_reference :items, :person, type: :uuid, foreign_key: { to_table: :zaiku_people }
end

# in your item.rb model
belongs_to :person, class_name: 'Zaiku::Person'
```

Of course you could also reference to `zaiku_organizations`.

#### Add logic to the Zaiku models

You can easily make your own model and let it inherit from one of the Zaiku models do add more behaviour and relations:

```ruby
# in your customer.rb
class Customer < Zaiku::Organization
  # Associations
  has_many :vehicles
  has_many :facilities

  def your_own_methods
  end
end
```

### OAuth Flow

From any point in your application you can start using the ZAIKU Directory OAuth2 flow with

```ruby
redirect_to zaiku.new_session_path
```

This will redirect the user to the OAuth Authorize endpoint of the ZAIKU Directory `.../oauth/authorize` and include all necessary parameters like your client_id.

#### Create or update Person and Organization data

After the user logged in successfully at the ZAIKU Directory a redirect will happen back to your application to `.../zaiku/sessions/approve` (or whatever you mounted the Engine to) - including the Authorization Grant Code.

Exchanging the Code for an AccessToken and querying user data from the API will happen automatically in the `Zaiku::SessionsController`.

All Zaiku models (`Zaiku::Person, Zaiku::Organization, Zaiku::OrganizationMembership`) in relation to the signed in user will automatically be created or updated (depending on if already present in your database).

#### Session handling

The Zaiku gem engine will set a cookie for the user after a successful OAuth flow: `cookies.encrypted[:person_id]`.

In your controllers include the concern `Zaiku::CookieBasedAuthentication` which will set:
```ruby
Current.user ||= Person.find_by(id: cookies.encrypted[:person_id])
````

You can then use `Current.user` anywhere.

As an alternative build your own concern and use the person_id from the encrypted cookie within your application as you like.


For **logout** use: `zaiku.session_path, method: :delete` or build your own controller for deleting the cookie.

#### Redirecting

The `zaiku.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin` which will then be used to redirect the user at the end of a completed & successful OAuth flow.


## Use Sandbox for testing

With the above described credentials you can connect right away to our Sandbox environment to get access to the demo app with demo users.

The UUID of people and organizations within the Sandbox are the same as within the fixtures of this gem (see `people.yml`and `organizations.yml`).

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

To log in by yourself and test the process manually, use the demo person with the credentials you can find in `test/system/zaiku/sessions_test.rb`.


## Use of dummy app

You can use the included dummy app as a showcase for the workflow and to adjust your own application. To set up the dummy application properly, go into `test/dummy` and use [puma-dev](https://github.com/puma/puma-dev) like this:

```shell
puma-dev link -n 'zaiku-app'
```
This will make the dummy app available at: [http://zaiku-app.test](http://zaiku-app.test/)

If you use the provided OAuth credentials from above and test this against the Sandbox, everything should work as the redirect URLs for [http://zaiku-app.test](http://zaiku-app.test/) are approved within the Sandbox.


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
