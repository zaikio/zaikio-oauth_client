require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "starting a new session" do
    visit '/zaikio/sessions/new'

    fill_in "E-Mail", with: "fgalli@example.com"
    fill_in "Password", with: "20dfd450-256b-4097-bc50-6c25437562ef"

    click_on "Login"

    assert_text "Welcome"
  end
end
