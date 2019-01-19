# frozen_string_literal: true

json.extract! project, :id, :name, :link, :image_url, :blog_url, :certificate_url, :invoice_url, :longitude, :latitude,
              :carbon_offset, :country, :type, :created_at, :updated_at
json.url admin_project_url(project, format: :json)