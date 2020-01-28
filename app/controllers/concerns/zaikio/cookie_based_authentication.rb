module Zaikio
  module CookieBasedAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate
    end

    private

    def authenticate
      Current.user ||= Person.find_by(id: cookies.encrypted[:zaikio_person_id])
    end
  end
end
