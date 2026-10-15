# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CancellationRequest
        def initialize(reason:)
          @payload = { reason: reason }
        end

        def to_hash
          @payload.dup
        end
      end
    end
  end
end
