module Zaikio
  module CookieBasedAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate, :redirect_unless_authenticated
    end

    private

    def authenticate
      Current.user ||= Person.find_by(id: cookies.encrypted[:zaikio_person_id])
    end

    def redirect_unless_authenticated
      if Current.user.blank?
        cookies.encrypted[:origin] = request.fullpath
        redirect_to zaikio.new_session_path
      end
    end
  end
end
