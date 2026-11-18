# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class CustomerEventDataDto
        attr_reader :transferred_from, :transferred_to

        def initialize(data)
          @transferred_from = data['transferred_from'] || []
          @transferred_to = data['transferred_to'] || []
        end

        def to_hash
          { transferred_from: @transferred_from, transferred_to: @transferred_to }
        end
      end
    end
  end
end
