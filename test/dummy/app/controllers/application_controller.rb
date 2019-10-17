class ApplicationController < ActionController::Base
  include Zaiku::CookieBasedAuthentication
end
