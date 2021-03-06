# frozen_string_literal: true

FactoryBot.define do
  factory :card_charge do |card_charge|
    card_charge.sequence(:stripe_customer_id) { |n| n }

    factory :card_charge_paid do
      currency { 'sek' }
      paid { true }

      factory :card_charge_monthly do
        amount { 80_00 }
      end

      factory :card_charge_gift_card do
        amount { 220_00 }
        gift_card { true }
      end

      factory :card_charge_flight_offset do
        amount { 40_00 }
        flight_offset { true }
      end
    end
  end
end
