# frozen_string_literal: true

require 'uri'

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_carbon_offset = Project.total_carbon_offset

    my_amount_invested_usd_part =
      StripeEvent.payments(current_user).where(paid: true).where(currency: 'usd').sum('stripe_amount').to_i / 100
    my_amount_invested_sek_part =
      StripeEvent.payments(current_user).where(paid: true).where(currency: 'sek').sum('stripe_amount').to_i / 100
    my_amount_invested_eur_part =
      StripeEvent.payments(current_user).where(paid: true).where(currency: 'eur').sum('stripe_amount').to_i / 100

    @my_amount_invested_sek =
      (
        my_amount_invested_sek_part + my_amount_invested_usd_part * LifestyleChoice::SEK_PER_USD +
        my_amount_invested_eur_part * LifestyleChoice::SEK_PER_EUR
      ).round

    @my_carbon_offset = (@my_amount_invested_sek / LifestyleChoice::SEK_PER_TONNE.to_f).round(1)

    @my_neutral_months = StripeEvent.payments(current_user).where(paid: true).count
    @my_neutral_months = 1 if @my_neutral_months == 0

    @unique_climate_neutral_users = User.with_active_subscription.count

    @user_top_list = User.where("users.stripe_customer_id != ''")
                         .left_joins(:stripe_events)
                         .where('stripe_events.paid = true')
                         .select('users.id, users.user_name, COUNT(1)')
                         .group('users.id')
                         .order(Arel.sql('COUNT(1) DESC'))

    @country_top_list = User.where("users.stripe_customer_id != ''")
                            .left_joins(:stripe_events)
                            .where('stripe_events.paid = true')
                            .select('users.country, COUNT(1)')
                            .group('users.country')
                            .order(Arel.sql('COUNT(1) DESC'))

    @projects = Project.all.order(created_at: :desc).limit(5)

    # TODO: This is view logic and should be in a helper
    @social_quote = I18n.t('i_have_lived_climate_neutral_for_join_me', count: @my_neutral_months)
    @encoded_social_quote = CGI.escape(@social_quote + ' -> ' + I18n.t('goclimateneutral_url'))

    # TODO: This is only ever true if the user navigates straight to this page
    # and is remembered. Logging in through the login form sets last_seen_at to
    # a current time before reaching here, and going to any other page before
    # coming here does the same. This results in this popup showing up very
    # seldomly making its existence not really worth it. Either remove it or
    # change the logic to something that happens reasonably often to justify
    # its existence.
    @should_show_share_popup = current_user.last_seen_at < 24.hour.ago
  end
end
