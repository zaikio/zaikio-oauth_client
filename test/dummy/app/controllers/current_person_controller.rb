class CurrentPersonController < ApplicationController
  def show
    directory = Zaikio.directory(token: Current.user.access_tokens.valid.first.token)
    remote_person = directory.person

    render plain: remote_person.attributes.to_json
  end
end
