require "test_helper"

class Zaikio::OAuthClient::RoutingTest < ActionDispatch::IntegrationTest
  def setup
    @routes = Zaikio::OAuthClient::Engine.routes
  end

  include Zaikio::OAuthClient::Engine.routes.url_helpers

  test "routing without client_name" do
    assert_equal new_session_path, "/zaikio/sessions/new"
    assert_recognizes({ controller: "sessions", action: "new" }, "/sessions/new")

    assert_equal approve_session_path, "/zaikio/sessions/approve"
    assert_recognizes({ controller: "sessions", action: "approve" }, "/sessions/approve")

    assert_equal session_path, "/zaikio/session"
    assert_recognizes({ controller: "sessions", action: "destroy" }, { path: "/session", method: :delete })

    assert_equal new_connection_path, "/zaikio/connections/new"
    assert_recognizes({ controller: "zaikio/o_auth_client/connections", action: "new" }, "/connections/new")

    assert_equal approve_connection_path, "/zaikio/connections/approve"
    assert_recognizes({ controller: "zaikio/o_auth_client/connections", action: "approve" }, "/connections/approve")
  end

  test "routing including a custom :client_name" do
    assert_equal new_session_path(client_name: "foo"), "/zaikio/foo/sessions/new"
    assert_recognizes({ controller: "sessions", action: "new", client_name: "foo" }, "/foo/sessions/new")

    assert_equal approve_session_path(client_name: "foo"), "/zaikio/foo/sessions/approve"
    assert_recognizes({ controller: "sessions", action: "approve", client_name: "foo" }, "/foo/sessions/approve")

    assert_equal session_path(client_name: "foo"), "/zaikio/foo/session"
    assert_recognizes({ controller: "sessions", action: "destroy", client_name: "foo" },
                      { path: "/foo/session", method: :delete })

    assert_equal new_connection_path(client_name: "foo"), "/zaikio/foo/connections/new"
    assert_recognizes({ controller: "zaikio/o_auth_client/connections", action: "new", client_name: "foo" },
                      "/foo/connections/new")

    assert_equal approve_connection_path(client_name: "foo"), "/zaikio/foo/connections/approve"
    assert_recognizes({ controller: "zaikio/o_auth_client/connections", action: "approve", client_name: "foo" },
                      "/foo/connections/approve")
  end
end
