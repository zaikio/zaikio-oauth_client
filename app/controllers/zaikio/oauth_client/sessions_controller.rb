module Zaikio
  module OAuthClient
    class SessionsController < ApplicationController
      include Zaikio::OAuthClient::Authenticatable
    end
  end
end
