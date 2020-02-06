class ApplicationController < ActionController::Base
  include Zaikio::CookieBasedAuthentication

  default_form_builder Zaikio::FormBuilder
  helper Zaikio::ApplicationHelper
  helper Zaikio::FormTagHelper
end
