# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CreateSubscriptionPlanRequestDto
        def initialize(name:, amount:, currency:, intervals:, description: '', is_active: true)
          @name = name
          @amount = amount
          @currency = currency
          @intervals = intervals
          @description = description
          @is_active = is_active
        end

        def to_hash
          {
            name: @name,
            description: @description,
            amount: @amount,
            currency: @currency,
            intervals: @intervals,
            is_active: @is_active
          }
        end
      end
    end
  end
end
