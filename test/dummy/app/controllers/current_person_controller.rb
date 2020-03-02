class CurrentPersonController < ApplicationController
  def show
    directory = Zaikio::OAuthClient.directory(token: Current.user.last_valid_or_expired_token)
    remote_person = directory.person

    render plain: remote_person.attributes.to_json
  end
end
