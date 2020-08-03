module Zaikio
  class CleanupAccessTokensJob < ApplicationJob
    def perform
      Zaikio::AccessToken.with_invalid_refresh_token.delete_all
    end
  end
end
