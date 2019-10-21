module Zaiku
  class ApplicationController < ActionController::Base
    include Zaiku::CookieBasedAuthentication
    # protect_from_forgery with: :exception
  end
end
