require_dependency "zaiku/concerns/cookie_based_authentication"

module Zaiku
  class ApplicationController < ActionController::Base
    # protect_from_forgery with: :exception
  end
end
