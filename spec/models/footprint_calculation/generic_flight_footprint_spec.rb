# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FootprintCalculation::GenericFlightFootprint do
  describe '#footprint' do
    it 'returns correct footprint for long haul flight' do
      # ARN-JFK, 6292 km -> 1167 kg co2e
      flight_footprint = described_class.new(6292, :economy)
      expect(flight_footprint.footprint).to eq(1167)
    end

    it 'returns correct footprint for medium haul flight' do
      # ARN-ZRH, 1501 km -> 313 kg co2e
      flight_footprint = described_class.new(1501, :economy)
      expect(flight_footprint.footprint).to eq(313)
    end

    it 'returns correct footprint for short haul flight' do
      # ARN-MUC, 1317 km -> 284 kg co2e
      flight_footprint = described_class.new(1317, :economy)
      expect(flight_footprint.footprint).to eq(284)
    end

    it 'returns correct footprint for short haul flight below lowest detour constant limit' do
      # ARN-MUC, 394 km -> 132 kg co2e
      flight_footprint = described_class.new(394, :economy)
      expect(flight_footprint.footprint).to eq(132)
    end

    it 'returns correct footprint for business cabin class' do
      # ARN-MUC, 1317 km -> 373 kg co2e
      flight_footprint = described_class.new(1317, :business)
      expect(flight_footprint.footprint).to eq(373)
    end

    it 'returns correct footprint for first cabin class' do
      # ARN-MUC, 1317 km -> 710 kg co2e
      flight_footprint = described_class.new(1317, :first)
      expect(flight_footprint.footprint).to eq(710)
    end
  end
end
