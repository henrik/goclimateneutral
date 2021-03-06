# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionMailer, type: :mailer do
  let(:user) { create(:user, stripe_customer_id: 'test_id', region: 'us') }

  before do
    create(:card_charge, stripe_customer_id: 'test_id', paid: true)
  end

  shared_examples 'subscription email' do
    it 'sends an email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['info@goclimateneutral.org'])
    end

    it 'sets Sendgrid unsubscribe group' do
      expect(mail['asm'].value).to eq("{:group_id=>#{SENDGRID_ASM_GROUP_IDS[:subscription]}}")
    end
  end

  describe '.one_more_month_email' do
    subject(:mail) { described_class.with(email: user.email).one_more_month_email }

    it_behaves_like 'subscription email'

    it 'renders the subject' do
      expect(mail.subject).to eql('Thank you!')
    end

    it 'matches number of months' do
      expect(mail.body.encoded).to match('You have lived a climate neutral life for 1 month.')
    end
  end

  describe '.one_more_year_email' do
    subject(:mail) { described_class.with(email: user.email).one_more_year_email }

    before do
      create_list(:card_charge, 12, stripe_customer_id: 'test_id', paid: true)
    end

    it_behaves_like 'subscription email'

    it 'renders the subject' do
      expect(mail.subject).to eql('Thank you!')
    end

    it 'matches number of months' do
      expect(mail.body.encoded).to match('You have lived a climate neutral life for 1 year.')
    end
  end

  describe '.payment_failed_email' do
    subject(:mail) { described_class.with(email: user.email).payment_failed_email }

    it_behaves_like 'subscription email'

    it 'renders the subject' do
      expect(mail.subject).to eql('Unfortunately your payment has failed')
    end

    it 'renders a payment has failed text' do
      expect(mail.body.encoded).to match('Unfortunately your payment has failed')
    end
  end
end
