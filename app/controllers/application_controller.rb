# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  helper_method :current_region, :canonical_url

  protected

  def default_url_options
    # Make region fallback explicit to not confuse path helpers with additional
    # path parameters.
    super.merge(region: current_region.slug)
  end

  def canonical_query_params
    []
  end

  def render_not_found
    raise ActionController::RoutingError, 'Not found'
  end

  def current_region
    Region.from_slug(params[:region])
  end

  def canonical_url
    @canonical_url ||= url_for(
      protocol: 'https', host: 'www.goclimateneutral.org', port: nil, **canonical_query_params_for_request
    )
  end

  def force_sv_locale
    I18n.locale = :sv
  end

  def permit_params_locale
    I18n.locale = params[:locale] if params[:locale].present?
  end

  def force_en_locale
    I18n.locale = :en
  end

  def after_sign_in_path_for(*)
    session['user_return_to'] || dashboard_path
  end

  def blog
    redirect_to "https://www.goclimateneutral.org/blog#{request.fullpath.gsub('/blog', '')}", status: :moved_permanently
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:stripe_customer_id, :user_name, :country, :region])
    devise_parameter_sanitizer.permit(:account_update, keys: [:user_name, :country, :region])
  end

  def cost_per_tonne
    case current_region.currency
    when Currency::SEK
      LifestyleChoice::BUSINESS_SEK_PER_TONNE
    when Currency::USD
      LifestyleChoice::BUSINESS_SEK_PER_TONNE / LifestyleChoice::SEK_PER_USD
    when Currency::EUR
      LifestyleChoice::BUSINESS_SEK_PER_TONNE / LifestyleChoice::SEK_PER_EUR
    end
  end

  def handle_record_not_found
    render 'errors/not_found', status: :not_found
  end

  private

  def set_locale
    I18n.locale = current_region.locale
  end

  def canonical_query_params_for_request
    request.query_parameters.to_h
           .transform_keys(&:to_sym)
           .filter { |param, _| canonical_query_params.include?(param) }
  end
end
