# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeEvent do
  before(:example) do
    @u = create(:user, stripe_customer_id: 'customer_test_id')
  end

  describe '#update_events' do
    it 'inserts one stripeevent if event a Gift Card' do
      @u = create(:user, stripe_customer_id: nil)
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id": "evt_1DSOhgHwuhGySQCdbfGo5Bsz","object": "event","api_version": "2018-05-21","created": 1541249896,"data": {"object":{"id":"ch_1DSOhfHwuhGySQCdlVpJYYwn","object":"charge","amount":22000,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DSOhgHwuhGySQCdbrszdsyi","captured":true,"created":1541249895,"currency":"sek","customer":null,"description":"Gift Card 3 months","destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":49,"seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DSOhfHwuhGySQCdlVpJYYwn/refunds"},"review":null,"shipping":null,"source":{"id":"card_1DSOhcHwuhGySQCdqmQcEMmx","object":"card","address_city":null,"address_country":null,"address_line1":null,"address_line1_check":null,"address_line2":null,"address_state":null,"address_zip":null,"address_zip_check":null,"brand":"Visa","country":"US","customer":null,"cvc_check":"pass","dynamic_last4":null,"exp_month":11,"exp_year":2019,"fingerprint":"AFDR1kTX598pXWiQ","funding":"credit","last4":"4242","metadata":{},"name":"kalle.nilver@gmail.com","tokenization_method":null},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode": false,"pending_webhooks": 0,"request": {"id":"req_39TIfEf7bRrdY8","idempotency_key":null},"type": "charge.succeeded"}]}', object_class: OpenStruct))
      expect(Project.total_carbon_offset).to eq(0)
      StripeEvent.update_events
      expect(StripeEvent.count).to eq(1)
      expect(StripeEvent.last.stripe_event_id).to eq('ch_1DSOhfHwuhGySQCdlVpJYYwn')
      expect(StripeEvent.last.gift_card).to eq(true)
      expect(StripeEvent.last.stripe_customer_id).to eq(nil)
      expect(Project.total_carbon_offset).to eq(5)
    end

    it 'inserts one stripeevent if event is a charge and is paid' do
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"customer_test_id","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      StripeEvent.update_events
      expect(StripeEvent.last.stripe_event_id).to eq('test_charge_id')
      expect(StripeEvent.last.gift_card).to eq(false)
    end

    it 'should add a stripeevent if event is a charge and is not paid' do
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id_2","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id_2","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"customer_test_id","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":false,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      StripeEvent.update_events
      expect(StripeEvent.last.stripe_event_id).to eq('test_charge_id_2')
    end

    it 'inserts only one stripeevent even if update events is called two times' do
      expect(Stripe::Event).to receive(:list).with(limit: 1000).twice.and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"customer_test_id","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      StripeEvent.update_events
      StripeEvent.update_events
      expect(StripeEvent.count).to eq(1)
      expect(StripeEvent.last.gift_card).to eq(false)
    end

    it 'sends one more month email if payment is new' do
      create(:stripe_event, stripe_customer_id: 'customer_test_id', paid: true, stripe_object: 'charge', currency: 'usd')
      expect(SubscriptionMailer).to receive_message_chain(:with, :one_more_month_email, :deliver_now).and_return(SubscriptionMailer.with(email: @u.email))
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"customer_test_id","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      StripeEvent.update_events
      expect(StripeEvent.count).to eq(2)
      expect(StripeEvent.last.gift_card).to eq(false)
    end

    it 'sends one more year email if one year of payments has gone by' do
      create_list(:stripe_event, 11, stripe_customer_id: 'customer_test_id', paid: true, stripe_object: 'charge', currency: 'usd')
      expect(SubscriptionMailer).to receive_message_chain(:with, :one_more_year_email, :deliver_now).and_return(SubscriptionMailer.with(email: @u.email))
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"customer_test_id","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      StripeEvent.update_events
      expect(StripeEvent.count).to eq(12)
    end

    it 'does not send email if stripe_customer_id is null' do
      expect(SubscriptionMailer).not_to receive(:with)
      expect(Stripe::Event).to receive(:list).with(limit: 1000).and_return(JSON.parse('{"object": "list","data": [{"id":"test_event_id","object":"event","api_version":"2018-05-21","created":1541177568,"data":{"object":{"id":"test_charge_id","object":"charge","amount":500,"amount_refunded":0,"application":null,"application_fee":null,"balance_transaction":"txn_1DS5t6HwuhGySQCd5GOjhxnx","captured":true,"created":1541177567,"currency":"usd","customer":"null","description":null,"destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":31,"rule":"allow_if_liability_shift__enabled","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":null,"refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_1DS5t5HwuhGySQCdOWnW23bt/refunds"},"review":null,"shipping":null,"source":{"id":"src_1DS5t3HwuhGySQCdUL6pAOJG","object":"source","amount":500,"client_secret":"src_client_secret_DttgF3UYxJkfYT2vFcOLznQS","created":1541177568,"currency":"usd","flow":"redirect","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":"","line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"redirect":{"failure_reason":null,"return_url":"http://127.0.0.1:43799/users/edit/threedsecure?email=test@example.com&plan=5&updatecard=1&customer=cus_DttghuQmPDcww6","status":"succeeded","url":"https://hooks.stripe.com/redirect/authenticate/src_1DS5t3HwuhGySQCdUL6pAOJG?client_secret=src_client_secret_DttgF3UYxJkfYT2vFcOLznQS"},"statement_descriptor":null,"status":"consumed","three_d_secure":{"customer":"cus_DttghuQmPDcww6","card":"src_1DS5t0HwuhGySQCdsCDwlyNp","brand":"Visa","country":"US","cvc_check":"pass","exp_month":5,"exp_year":2022,"fingerprint":"nzH1WYKwGPJtfUhD","funding":"credit","last4":"3063","three_d_secure":"required","authenticated":true,"name":null,"address_line1_check":null,"address_zip_check":null,"tokenization_method":null,"dynamic_last4":null},"type":"three_d_secure","usage":"single_use"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_group":null}},"livemode":false,"pending_webhooks":0,"request":{"id":"req_LWExH85eS5Hg1f","idempotency_key":null},"type":"charge.succeeded"}]}', object_class: OpenStruct))
      emails = ActionMailer::Base.deliveries.count
      StripeEvent.update_events
      expect(ActionMailer::Base.deliveries.count).to eq(emails)
    end
  end
end
