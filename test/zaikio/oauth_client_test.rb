require "test_helper"

class MyLib
  class << self
    attr_reader :my_token

    def with_token(token)
      @my_token = token
      yield if block_given?
      @my_token = nil
    end
  end
end

class Zaikio::OAuthClient::Test < ActiveSupport::TestCase
  def configure
    Zaikio::OAuthClient.configure do |config|
      config.environment = :test
      config.register_client :warehouse do |warehouse|
        warehouse.client_id = "abc"
        warehouse.client_secret = "secret"
        warehouse.default_scopes = %w[directory.person.r]

        warehouse.register_organization_connection do |org|
          org.default_scopes = %w[directory.organization.r]
        end
      end

      yield(config) if block_given?
    end
  end

  def setup
    configure
  end

  test "is a module" do
    assert_kind_of Module, Zaikio::OAuthClient
  end

  test "has version number" do
    assert_not_nil ::Zaikio::OAuthClient::VERSION
  end

  test "it is configurable" do
    assert_equal :test,                   Zaikio::OAuthClient.configuration.environment
    assert_match "directory.zaikio.test", Zaikio::OAuthClient.configuration.host
    client_config = Zaikio::OAuthClient.configuration.find!("warehouse")
    assert_equal "abc", client_config.client_id
    assert_equal "secret", client_config.client_secret
    assert_equal %w[directory.person.r], client_config.default_scopes
    assert_equal %w[directory.organization.r], client_config.org_config.default_scopes
    assert_kind_of ::OAuth2::Client, client_config.oauth_client
    assert_equal client_config.oauth_client, Zaikio::OAuthClient.for(:warehouse)
    assert_equal client_config.oauth_client, Zaikio::OAuthClient.for
    assert_equal "oauth/authorize", client_config.oauth_client.options[:authorize_url]
    assert_equal "oauth/access_token", client_config.oauth_client.options[:token_url]
    assert_equal "abc", client_config.oauth_client.id
    assert_equal Zaikio::OAuthClient.configuration.host, client_config.oauth_client.site
  end

  test "gets valid access token" do
    access_token = Zaikio::OAuthClient::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 1.hour.from_now,
      scopes: %w[directory.organization.r directory.something.r]
    )

    assert_equal access_token, Zaikio::OAuthClient.get_access_token(
      bearer_type: "Organization",
      bearer_id: "123",
      scopes: %w[directory.something.r]
    )
  end

  test "generates refresh token" do
    access_token = Zaikio::OAuthClient::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 1.hour.ago,
      scopes: %w[directory.organization.r directory.something.r]
    )

    stub_request(:post, "http://directory.zaikio.test/oauth/access_token")
      .with(
        basic_auth: %w[abc secret],
        body: {
          "grant_type" => "refresh_token",
          "refresh_token" => access_token.refresh_token
        },
        headers: {
          "Accept" => "application/json"
        }
      )
      .to_return(status: 200, body: {
        "access_token" => "refreshed",
        "refresh_token" => "refresh_of_refreshed",
        "token_type" => "bearer",
        "scope" => "directory.organization.r,directory.something.r",
        "audiences" => ["warehouse"],
        "expires_in" => 600,
        "bearer" => {
          "id": "123",
          "type": "Organization"
        }
      }.to_json, headers: { "Content-Type" => "application/json" })

    refreshed_token = Zaikio::OAuthClient.get_access_token(
      bearer_type: "Organization",
      bearer_id: "123",
      scopes: %w[directory.something.r]
    )
    assert_not refreshed_token.expired?
    assert_equal %w[directory.organization.r directory.something.r], refreshed_token.scopes
    assert_equal "123", refreshed_token.bearer_id
    assert_equal "Organization", refreshed_token.bearer_type
    assert_equal "refreshed", refreshed_token.token
    assert_equal "refresh_of_refreshed", refreshed_token.refresh_token
    assert_not_equal access_token, refreshed_token
  end

  test "gets token via client credentials" do
    Zaikio::OAuthClient::AccessToken.delete_all

    stub_request(:post, "http://directory.zaikio.test/oauth/access_token")
      .with(
        basic_auth: %w[abc secret],
        body: {
          "grant_type" => "client_credentials",
          "scope" => "Org/123.directory.something.r"
        },
        headers: {
          "Accept" => "application/json"
        }
      )
      .to_return(status: 200, body: {
        "access_token" => "my-token",
        "refresh_token" => "refresh_token",
        "token_type" => "bearer",
        "scope" => "directory.something.r",
        "audiences" => ["warehouse"],
        "expires_in" => 600,
        "bearer" => {
          "id": "123",
          "type": "Organization"
        }
      }.to_json, headers: { "Content-Type" => "application/json" })

    access_token = Zaikio::OAuthClient.get_access_token(
      bearer_type: "Organization",
      bearer_id: "123",
      scopes: %w[directory.something.r]
    )
    assert_not access_token.expired?
    assert_equal %w[directory.something.r], access_token.scopes
    assert_equal "123", access_token.bearer_id
    assert_equal "Organization", access_token.bearer_type
    assert_equal "my-token", access_token.token
    assert_nil access_token.refresh_token # not set in client credentials
  end

  test "use with auth helper" do
    access_token = Zaikio::OAuthClient::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 1.hour.ago,
      scopes: %w[directory.organization.r directory.something.r]
    )

    configure do |config|
      config.around_auth do |at, block|
        MyLib.with_token(at.token) do
          block.call(at)
        end
      end
    end

    obj = OpenStruct.new
    obj.expects(:call)

    Zaikio::OAuthClient.with_auth(access_token) do
      obj.call
      assert_equal "abc", MyLib.my_token
    end
  end
end
