# frozen_string_literal: true

class BusinessInterestMailer < ApplicationMailer
  def notice_email(reply_to, number_of_employees, language)
    mail(
      to: 'info@goclimateneutral.org',
      cc: 'kalle@goclimateneutral.org',
      reply_to: reply_to,
      subject: 'Intresseanmälan från företag som vill klimatkompensera',
      body: "Intresseanmälan från: #{reply_to}, för #{number_of_employees} antal anställda, språk: #{language}"
    )
  end
end