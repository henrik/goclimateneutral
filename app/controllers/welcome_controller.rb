class WelcomeController < ApplicationController

  def index
    @unique_climate_neutral_users = User.distinct.pluck(:stripe_customer_id).count
    @total_carbon_offset = Project.total_carbon_offset
  end

  def plan
    @unique_climate_neutral_users = User.distinct.pluck(:stripe_customer_id).count
    @total_carbon_offset = Project.total_carbon_offset
    @lifestyle_choice_co2 = LifestyleChoice.get_lifestyle_choice_co2
    gon.lifestyle_choice_co2 = @lifestyle_choice_co2
    gon.locale = I18n.locale
    gon.SEK_PER_TONNE = LifestyleChoice::SEK_PER_TONNE
    gon.BUFFER_SIZE = LifestyleChoice::BUFFER_SIZE
    gon.SEK_PER_DOLLAR = LifestyleChoice::SEK_PER_DOLLAR
    gon.price_info_popup_content = I18n.t('price_info_popup_content')
  end

  def about
  end

  def companies
  end

  def contact
  end

  def faq
  end

  def friendlyguide
  end

  def press
    @press_images = Dir.glob("app/assets/images/press/*.*")
    @press_social_images = Dir.glob("app/assets/images/press_social/*.*")
  end

  def our_projects
    @projects = Project.all.order(date_bought: :desc)
  end

  def transparency
    @projects = Project.all.order(date_bought: :desc)
    @unique_climate_neutral_users = User.distinct.pluck(:stripe_customer_id).count
    @total_carbon_offset = Project.total_carbon_offset
    @cost_in_sek = Project.sum (:cost_in_sek)
    @payouts_in_sek = (StripePayout.sum(:amount) / 100)
  end

end
