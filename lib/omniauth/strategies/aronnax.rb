require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Aronnax < OmniAuth::Strategies::OAuth2
      option :name, :aronnax
      option :client_options,
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token"

      uid { raw_info["id"] }
      info { { email: raw_info["email"] } }

      def raw_info
        @raw_info ||= access_token.get("/api/v1/me").parsed
      end
    end
  end
end
