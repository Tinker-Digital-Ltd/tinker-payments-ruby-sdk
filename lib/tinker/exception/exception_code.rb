# frozen_string_literal: true

module Tinker
  module Exception
    class ExceptionCode
      API_ERROR = 1000
      NETWORK_ERROR = 2000
      AUTHENTICATION_ERROR = 3000
      INVALID_PAYLOAD = 4000
      WEBHOOK_ERROR = 5000
      STREAM_ERROR = 6000
      CLIENT_ERROR = 7000
    end
  end
end

