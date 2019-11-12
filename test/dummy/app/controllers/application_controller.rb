class ApplicationController < ActionController::Base
  include Zaiku::CookieBasedAuthentication
  default_form_builder Zaiku::FormBuilder
  helper Zaiku::ApplicationHelper
end
