# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :invoices
  has_many :climate_report_invoices

  attribute :co2e, :greenhouse_gases

  validates_presence_of :name, :co2e, :date_bought, :latitude, :longitude, :image_url, :blog_url, :short_description
  validates :offset_type, inclusion: %w[GS CDM+GS CDM], allow_nil: true

  def self.total_carbon_offset
    cdm_project_cost = Project.where("offset_type = 'CDM'").sum('cost_in_sek')
    cdm_project_tonnes = Project.where("offset_type = 'CDM'").sum('co2e') / 1000
    user_offset = ((CardCharge.total_in_sek - cdm_project_cost) / LifestyleChoice::SEK_PER_TONNE).round +
                  cdm_project_tonnes

    user_offset + (BigDecimal(ClimateReportInvoice.sum(:co2e) + Invoice.sum(:co2e)) / 1000).ceil
  end

  def co2e_reserved
    @co2e_reserved ||= GreenhouseGases.new(invoices.sum(:co2e) + climate_report_invoices.sum(:co2e))
  end

  def co2e_available
    co2e - co2e_reserved
  end

  def map_url
    "https://www.google.com/maps?z=15&t=k&q=loc:#{latitude}+#{longitude}"
  end
end
