require "test_helper"

module Zaikio
  class CleanupAccessTokensJobTest < ActiveSupport::TestCase
    test "deletes expired access token" do
      job = Zaikio::CleanupAccessTokensJob.new

      assert_difference "Zaikio::AccessToken.count", -1 do
        job.perform
      end

      assert_raise ActiveRecord::RecordNotFound do
        zaikio_access_tokens(:expired_access_token)
      end
    end
  end
end
