# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CreateSubscriptionPlanRequestDto
        def initialize(name:, amount:, currency:, intervals:, description: '', is_active: true, features_json: nil)
          @name = name
          @amount = amount
          @currency = currency
          @intervals = intervals
          @description = description
          @is_active = is_active
          @features_json = features_json
        end

        def to_hash
          hash = {
            name: @name,
            description: @description,
            amount: @amount,
            currency: @currency,
            intervals: @intervals,
            is_active: @is_active
          }
          hash[:features_json] = @features_json unless @features_json.nil?
          hash
        end
      end
    end
  end
end
