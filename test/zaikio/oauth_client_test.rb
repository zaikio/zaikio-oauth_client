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

      config.register_client :other_app do |other_app|
        other_app.client_id = "def"
        other_app.client_secret = "secret"
        other_app.default_scopes = %w[directory.person.r]

        other_app.register_organization_connection do |org|
          org.default_scopes = %w[directory.organization.r]
        end
      end

      yield(config) if block_given?
    end
  end

  def org_token
    "eyJraWQiOiJhNmE1MzFjMGZhZTVlNWE1MDAzZDI2ZTRhMTIwMmIwNjg2ZDFkNTRjNGZhYTViZDlkZTBjMzdkY2JkY2RkYzdlIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJaQUkiLCJzdWIiOiJPcmdhbml6YXRpb24vYjE0NzVmNjUtMjM2Yy01OGI4LTk2ZTEtZTE3NzhiNDNiZWI3IiwiYXVkIjpbIk9yZ2FuaXphdGlvbi9iMTQ3NWY2NS0yMzZjLTU4YjgtOTZlMS1lMTc3OGI0M2JlYjciXSwianRpIjoiNWRmNDU5MGUtNzM4Mi00YTMxLWE1N2YtYWUwZTBjZTkwMmYyIiwibmJmIjoxNTg1ODM5NDQ0LCJleHAiOjMzMTQyNzUxODQ0LCJqa3UiOiJodHRwczovL2RpcmVjdG9yeS5oYy50ZXN0L2FwaS92MS9qd3RfcHVibGljX2tleXMiLCJzY29wZSI6WyJkaXJlY3RvcnkuYnVzaW5lc3NfcmVsYXRpb25zaGlwcy5ydyIsImRpcmVjdG9yeS5tYWNoaW5lcy5ydyIsImRpcmVjdG9yeS5vcmdhbml6YXRpb24uciIsImRpcmVjdG9yeS5vcmdhbml6YXRpb25fbWVtYmVycy5yIiwiZGlyZWN0b3J5LnNpdGVzLnJ3IiwiZGlyZWN0b3J5LnNvZnR3YXJlLnJ3Il19.NXUx3WUdcnUHlNG6s_fpEt2aH8xa-NFwNVF8vtk15P1DhJdP2e-vsFtOgRpwMrQc6MwDpaBG0L4PYV-NSLIU0Zqm1SLlWTodoAGWr31uwFUji0_8aBNsiIXVEhr5xfWYckUlw44xkcLAoD1Jo5t3BJvXdlQlGtgWg7jTj8rBRnafN5gm_ebbB17_TDohTnpMZQxOi8iKdl-hCAMHs3CjbN_TxHAblQbnhxvx01OhDrMOVNqsQpH3hGcr-rSihO85UpoAwDfqidiiGtnCgUsE5p8QHIqO8wgGAGqUHutg7W4GRH_T_OAfS7VbH9G60mazWYIhWW-JAxh-KRkg0wcP5g" # rubocop:disable Layout/LineLength
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
    assert_match "hub.zaikio.test",       Zaikio::OAuthClient.configuration.host
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
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    access_token = Zaikio::AccessToken.create!(
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

  test "removes blacklisted tokens" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns(["23d5b639-7d7b-4583-829b-159a08d0c099"])
    Zaikio::AccessToken.create!(
      id: "23d5b639-7d7b-4583-829b-159a08d0c099",
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 10.hours.from_now,
      scopes: %w[directory.organization.r directory.something.r]
    )
    access_token2 = Zaikio::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "def",
      refresh_token: "ghi",
      expires_at: 1.hour.from_now,
      scopes: %w[directory.organization.r directory.something.r]
    )

    assert_equal access_token2, Zaikio::OAuthClient.get_access_token(
      bearer_type: "Organization",
      bearer_id: "123",
      scopes: %w[directory.something.r]
    )
  end

  test "uses token from correct client" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    Zaikio::AccessToken.create!(
      id: "23d5b639-7d7b-4583-829b-159a08d0c099",
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 10.hours.from_now,
      scopes: %w[directory.organization.r directory.something.r]
    )
    access_token2 = Zaikio::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "other_app",
      token: "def",
      refresh_token: "ghi",
      expires_at: 1.hour.from_now,
      scopes: %w[directory.organization.r directory.something.r]
    )

    Zaikio::OAuthClient.with_client("other_app") do
      assert_equal access_token2, Zaikio::OAuthClient.get_access_token(
        bearer_type: "Organization",
        bearer_id: "123",
        scopes: %w[directory.something.r]
      )
    end
  end

  test "generates refresh token" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    access_token = Zaikio::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: "def",
      expires_at: 1.hour.ago,
      scopes: %w[directory.organization.r directory.something.r]
    )

    stub_request(:post, "http://hub.zaikio.test/oauth/access_token")
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

  test "gets token via client credentials if refresh token is not present" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    Zaikio::AccessToken.create!(
      bearer_type: "Organization",
      bearer_id: "123",
      audience: "warehouse",
      token: "abc",
      refresh_token: nil,
      expires_at: 1.hour.ago,
      scopes: %w[directory.organization.r directory.something.r]
    )

    stub_request(:post, "http://hub.zaikio.test/oauth/access_token")
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
        "access_token" => org_token,
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

    access_token2 = Zaikio::OAuthClient.get_access_token(
      bearer_type: "Organization",
      bearer_id: "123",
      scopes: %w[directory.something.r]
    )
    assert_not access_token2.expired?
    assert_equal %w[directory.something.r], access_token2.scopes
    assert_equal "123", access_token2.bearer_id
    assert_equal "Organization", access_token2.bearer_type
    assert_equal org_token, access_token2.token
    assert_equal "5df4590e-7382-4a31-a57f-ae0e0ce902f2", access_token2.id
    assert_nil access_token2.refresh_token # not set in client credentials
  end

  test "gets token via client credentials" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    Zaikio::AccessToken.delete_all

    stub_request(:post, "http://hub.zaikio.test/oauth/access_token")
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
        "access_token" => org_token,
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
    assert_equal org_token, access_token.token
    assert_equal "5df4590e-7382-4a31-a57f-ae0e0ce902f2", access_token.id
    assert_nil access_token.refresh_token # not set in client credentials
  end

  test "use with auth helper" do
    Zaikio::JWTAuth.stubs(:blacklisted_token_ids).returns([])
    access_token = Zaikio::AccessToken.create!(
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
