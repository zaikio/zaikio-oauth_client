# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

* Added: Rescue and return no access token on `bearer_does_not_exit` error.

## 0.21.2 - 2022-10-18

* Fix: Use latest access token instead of first valid one in case user granted new permissions

## 0.21.1 - 2022-10-13

* Fix `access_token` can be nil when deleting a session so add guard for this.

## 0.21.0 - 2022-10-10

* Refactor `Zaikio::OAuthClient.client_name` to be thread-safe

* Support `:app_name` and `:redirect_uri` parameters with subscription flow

## 0.20.0 - 2022-08-08

* Support prefilled person and organization data

## 0.19.3 - 2022-08-03

* Fix: only include valid or refreshable access token in `find_active_access_token`

## 0.19.2 - 2022-08-03

* Fix `logged_in_as` to return access token ID

## 0.19.1 - 2022-08-03

* Fix `logged_in_as` helper to create a proper access token

## 0.19.0 - 2022-08-03

* Do not store refresh tokens from client credentials flow to improve security ([until they are removed by the hub](https://docs.zaikio.com/changelog/2022-08-09_client-credentials-drop-refresh-token.html))
* Do not redeem refresh tokens in `get_access_token` instead use client credentials flow so that only users redeem refresh tokens
* Automatically revoke access token on logout (security)
* Add `Zaikio::OAuthClient.find_active_access_token( session[:zaikio_access_token_id])` that should be used to find the latest valid access token. If the (redirect) access token e.g. was revoked (user disconnected, security breach, ...) the user shall be logged out.
* Add `Zaikio::AccessToken#revoke!`

## 0.18.1 - 2022-04-29

* Relax dependency on `zaikio-jwt_auth`, allow versions 2.x

## 0.18.0 - 2022-04-26

* **BREAKING:** Encrypt `token` & `refresh_token` with [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html#setup):
  1. Run `rails db:encryption:init` per environment and copy the values to your encrypted credentials
  2. Run `rails zaikio_oauth_client:install:migrations` and `rails db:migrate` to encrypt stored access tokens

## 0.17.2 - 2022-01-07

* Fix broken Rubocop auto-corrected code.

## 0.17.1 - 2022-01-07

**Do not use, please go straight to v0.17.2**

* Retry SSO-flow if code is not given
* Set `allow_other_host: true` when redirecting to Hub (required for Rails 7 strict
  redirect policy). This property is backwards-compatible with older versions, it's only
  used in Rails 7+ when `ActionController::Base.raise_on_open_redirects = true` is set.

## 0.17.0 - 2021-09-23

* Retry SSO-flow if code is not valid (anymore)

## 0.16.0 - 2021-08-25

* Support `prompt_email_confirmation` option for SSO

## 0.15.1 - 2021-08-20

* Consider `valid_for` when fetching AccessTokens from the database, and only return
  tokens which meet the expected validity period. This reduces the likelihood of needing
  to refresh the token before you can use it.

## 0.15.0 - 2021-08-13

* Don't return access tokens which are due to expire in <30 seconds from now, and allow
  configuring this property with the `valid_for` keyword argument.

## 0.14.0 - 2021-06-18

* Support `prompt` option for SSO
* Remove `redirect_with_error=1` since it is now the default and deprecated.

## 0.13.0 - 2021-04-28

* Allow passing `?lang`, or set the default to `I18n.locale`, when starting a new OAuth session

## 0.12.1 - 2021-04-23

* Add `Zaikio::OAuthClient::SystemTestHelper` for working with system tests
  ([instructions here](https://github.com/zaikio/zaikio-oauth_client/blob/main/README.md#testing))

## 0.12.0 - 2021-04-23

* **BREAKING CHANGE:** Instead of working `cookies.encrypted` we will switch to `session` because the session cookie will be `httponly` and therefore can prevent XSS attack that set the cookie to another value. See also: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies

## 0.11.1 - 2021-04-21

* Update zaikio-jwt_auth dependency

## 0.11.0 - 2021-04-19

* Send `redirect_with_error=1` to redirect flow and handle errors like in OAuth spec.
* Support `error_path_for` for custom error handling.
* Automatically set `state` parameter for OAuth login and check response to protect
  against replay attacks.

## 0.10.0 - 2021-04-15

* Remove Access Token Lookups Queries from Log
* Use configured logger for AccessToken queries
* Support `:organization_id` parameter with subscription flow

## 0.9.0 - 2021-04-13

* Add support for subscription flow (for setting up a plan)

## 0.8.1 - 2021-03-31

* Destroy access token with invalid refresh token

## 0.8.0 - 2021-03-30

* Always destroy old access token after successful Hub API call in `Zaikio::AccessToken#refresh!` and return `nil` if refreshing fails.
* Add `.find_usable_access_token` helper method to get a token without making a Hub API call to refresh it

## 0.7.2 - 2021-03-25

* Replace dependency on `rails` with a more specific dependency on `railties` and friends

## 0.7.1 - 2021-03-17

* Fix incorrect const_defined? behaviour when initializing without zaikio-hub-models gem

## 0.7.0

* Don't set `session[:origin]` when passing `?origin` to `new_session_path`
* `show_signup`, `force_login` and `state` params are now passed through `new_session_path`.

## 0.6.1

* Fixed token lookup by searching through requested scopes not through granted scopes. You need to run `$ rails zaikio_oauth_client:install:migrations` to apply latest migrations.

## 0.6.0

* Improved index to improve access token lookup, run `$ rails zaikio_oauth_client:install:migrations` to apply

## 0.5.1

* Fixed Namespace for Models gem

## 0.5.0

* **BREAKING** Renames `Zaikio::Directory` to `Zaikio::Hub`

## 0.4.4 - 2021-01-19

* Fix another compatibility issue with Ruby 3.0

## 0.4.3 - 2021-01-15

* Automatically publish to RubyGems

## 0.4.2 - 2021-01-11

* Fix compatibility issues with Ruby 3.0
