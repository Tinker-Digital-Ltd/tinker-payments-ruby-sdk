# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class OnboardingEventDataDto
        attr_reader :message

        def initialize(data)
          @message = data.fetch('message', '').to_s
        end

        def to_hash
          { 'message' => @message }
        end
      end
    end
  end
end
