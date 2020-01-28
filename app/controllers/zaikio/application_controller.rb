module io
  class ApplicationController < ActionController::Base
    include Zaikio::CookieBasedAuthentication
    # protect_from_forgery with: :exception
  end
end
