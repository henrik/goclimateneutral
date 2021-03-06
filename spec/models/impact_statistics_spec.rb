# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactStatistics do
  let!(:subscriber_payment_sek) do
    create(:card_charge_monthly, created_at: Date.new(2019, 1, 29),
                                 amount: 80_00, # 80 SEK = 2 tonnes
                                 currency: 'sek')
  end
  let!(:subscriber_payment_usd) do
    # 80 USD is the lowest cost evenly dividable by our cost in tonnes = 17 tonnes
    create(:card_charge_monthly, created_at: Date.new(2019, 1, 30),
                                 amount: 80_00,
                                 currency: 'usd')
  end
  let!(:subscriber_payment_eur) do
    create(:card_charge_monthly, created_at: Date.new(2019, 1, 31),
                                 amount: 8_00, # 8 EUR = 2 tonnes
                                 currency: 'eur')
  end
  let!(:gift_card_payment_sek) do
    create(:card_charge_gift_card, created_at: Date.new(2019, 1, 29),
                                   amount: 80_00, # 80 SEK = 2 tonnes
                                   currency: 'sek')
  end
  let!(:gift_card_payment_usd) do
    # 80 USD is the lowest cost evenly divisible by our cost in tonnes = 17 tonnes
    create(:card_charge_gift_card, created_at: Date.new(2019, 1, 30),
                                   amount: 80_00,
                                   currency: 'usd')
  end
  let!(:gift_card_payment_eur) do
    create(:card_charge_gift_card, created_at: Date.new(2019, 1, 31),
                                   amount: 8_00, # 8 EUR = 2 tonnes
                                   currency: 'eur')
  end
  let!(:flight_offset_payment_sek) do
    create(:card_charge_flight_offset, created_at: Date.new(2019, 1, 29),
                                       amount: 40_00, # 40 SEK = 1 tonne
                                       currency: 'sek')
  end
  let!(:invoice) { create(:invoice, created_at: Date.new(2019, 1, 29), co2e: 40_000, project: project) }
  let!(:project) { create(:project, created_at: Date.new(2019, 1, 29), co2e: 200_000) }
  let!(:past_project) { create(:project, created_at: Date.new(2019, 1, 16), co2e: 100_000) }

  describe '#initialize' do
    it 'sets subscriber_payments_tonnes for week with subscription payments' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(subscriber_payments_tonnes: 21))
    end

    it 'sets gift_cards_tonnes for weeks with gift card payments' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(gift_cards_tonnes: 21))
    end

    it 'sets flight_offsets_tonnes for weeks with flight offsets payments' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(flight_offsets_tonnes: 1))
    end

    it 'sets invoices_tonnes for weeks with invoices' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(invoices_tonnes: 40))
    end

    it 'sets total_sold_tonnes for weeks with sold tonnes' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(total_sold_tonnes: 83))
    end

    it 'sets bought_projects_tonnes for weeks with projects' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-28' => hash_including(bought_projects_tonnes: 200))
    end

    it 'adds empty weeks between start and end of period' do
      statistics = described_class.new

      expect(statistics.weeks.keys).to include('2019-01-21')
    end

    it 'sorts keys of weeks hash' do
      statistics = described_class.new

      expect(statistics.weeks.keys).to eq(%w[2019-01-14 2019-01-21 2019-01-28])
    end

    it 'sets 0 for any missing field' do
      statistics = described_class.new

      expect(statistics.weeks).to include('2019-01-21' => hash_including(
        subscriber_payments_tonnes: 0, gift_cards_tonnes: 0, invoices_tonnes: 0, total_sold_tonnes: 0,
        bought_projects_tonnes: 0
      ))
    end
  end
end
