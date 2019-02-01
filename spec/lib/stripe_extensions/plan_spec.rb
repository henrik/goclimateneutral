# frozen_string_literal: true

require 'rails_helper'
require 'stripe_extensions/plan'

RSpec.describe StripeExtensions::Stripe::Plan do
  describe '#retrieve_or_create_climate_offset_plan' do
    let(:monthly_amount) { 3.6 }
    let(:currency) { 'usd' }
    let(:plan) { Stripe::Plan.construct_from(stripe_json_fixture('plan.json')) }

    before do
      allow(Stripe::Plan).to receive(:retrieve).and_return(plan)
      allow(Stripe::Plan).to receive(:create).and_return(plan)
    end

    it 'attempts to retrieve existing plan' do
      Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

      expect(Stripe::Plan).to have_received(:retrieve)
    end

    it 'uses plan id in format "climate_offset_[monthly_amount]_[currency]_monthly"' do
      Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

      expect(Stripe::Plan).to have_received(:retrieve).with('climate_offset_3_6_usd_monthly')
    end

    context 'when plan exists' do
      it 'returns retrieved plan' do
        retrieved_plan = Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(retrieved_plan).to be(plan)
      end
    end

    context 'when plan does not already exist' do
      before do
        allow(Stripe::Plan).to receive(:retrieve).and_raise(
          Stripe::InvalidRequestError.new('No such plan: ', 'plan')
        )
      end

      it 'creates new plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create)
      end

      it 'uses plan id in format "climate_offset_[monthly_amount]_[currency]_monthly" for created plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create).with(hash_including(id: 'climate_offset_3_6_usd_monthly'))
      end

      it 'uses monthly billing interval for created plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create).with(hash_including(interval: 'month'))
      end

      it 'uses provided currency for created plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create).with(hash_including(currency: currency))
      end

      it 'uses provided amount for created plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create).with(hash_including(amount: 3_60))
      end

      it 'uses product name in format "Climate Offset [monthly_amount] [currency] Monthly" for created plan' do
        Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(Stripe::Plan).to have_received(:create)
          .with(hash_including(product: { name: 'Climate Offset 3.6 usd Monthly' }))
      end

      it 'returns created plan' do
        created_plan = Stripe::Plan.retrieve_or_create_climate_offset_plan(monthly_amount, currency)

        expect(created_plan).to be(plan)
      end
    end
  end
end