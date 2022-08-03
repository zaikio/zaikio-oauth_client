require "test_helper"

module Zaikio
  class AcessTokenTest < ActiveSupport::TestCase
    test "#refresh!" do
      Zaikio::JWTAuth.stubs(:revoked_token_ids).returns([])
      access_token = Zaikio::AccessToken.create!(
        bearer_type: "Organization",
        bearer_id: "123",
        audience: "warehouse",
        token: "abc",
        refresh_token: "def",
        expires_at: 1.hour.ago,
        scopes: %w[directory.organization.r directory.something.r],
        requested_scopes: %w[directory.organization.r directory.something.r]
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
            id: "123",
            type: "Organization"
          }
        }.to_json, headers: { "Content-Type" => "application/json" })

      refreshed_token = access_token.refresh!
      assert_not refreshed_token.expired?
      assert_equal %w[directory.organization.r directory.something.r], refreshed_token.scopes
      assert_equal "123", refreshed_token.bearer_id
      assert_equal "Organization", refreshed_token.bearer_type
      assert_equal "refreshed", refreshed_token.token
      assert_equal "refresh_of_refreshed", refreshed_token.refresh_token
      assert_not_equal access_token, refreshed_token
    end
  end
end
