# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhooks::StripeController, type: :controller do
  describe 'POST #create' do
    let(:valid_subscription_id) { 'sub_123' }
    let(:valid_invoice_id) { 'inv_123' }

    before do
      request.headers['Content-Type'] = 'application/json'
      allow(Rails.logger).to receive(:info)
    end

    context 'when new subscription is created' do
      let(:event_params) do
        {
          type: 'customer.subscription.created',
          data: {
            object: {
              id: valid_subscription_id
            }
          }
        }
      end

      it 'will create a new subscription' do
        expect do
          post :create, params: event_params
        end.to change(Subscription, :count).by(1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when subscription is deleted' do
      let!(:subscription) { create(:subscription, subscription_id: valid_subscription_id, status: :paid) }

      let(:event_params) do
        {
          type: 'customer.subscription.deleted',
          data: {
            object: {
              id: valid_subscription_id
            }
          }
        }
      end

      it 'will cancel the subscription' do
        expect do
          post :create, params: event_params
        end.to change { subscription.reload.status }.from('paid').to('canceled')
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when invoice is paid for subscription' do
      let!(:subscription) { create(:subscription, subscription_id: valid_subscription_id, status: :unpaid) }

      let(:event_params) do
        {
          type: 'invoice.paid',
          data: {
            object: {
              id: valid_invoice_id,
              subscription: valid_subscription_id
            }
          }
        }
      end

      it 'will mark the subscription as paid' do
        expect do
          post :create, params: event_params
        end.to change { subscription.reload.status }.from('unpaid').to('paid')
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when unhandled event type is comes' do
      let(:event_params) do
        {
          type: 'unknown.event',
          data: {
            object: {
              id: 'unknown_id'
            }
          }
        }
      end

      it 'logs the unhandled event and responds with no content' do
        expect(Rails.logger).to receive(:info).with('Unhandled event type: unknown.event')
        post :create, params: event_params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when invalid status changes occured' do
      let!(:subscription) { create(:subscription, subscription_id: valid_subscription_id, status: :unpaid) }

      let(:event_params) do
        {
          type: 'customer.subscription.deleted',
          data: {
            object: {
              id: valid_subscription_id
            }
          }
        }
      end

      it 'logs the error and responds with no content' do
        expect(Rails.logger).to receive(:info)
        post :create, params: event_params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when unexpected subscription params provided' do
      let(:event_params) do
        {
          type: 'customer.subscription.created',
          data: {
            object: {
              id: nil
            }
          }
        }
      end

      it 'logs the error and responds with no content' do
        expect(Rails.logger).to receive(:info).with(/Validation failed/)
        post :create, params: event_params
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when subscription could not found' do
      let(:event_params) do
        {
          type: 'customer.subscription.deleted',
          data: {
            object: {
              id: 'non_existent_id'
            }
          }
        }
      end

      it 'logs the error and responds with no content' do
        expect(Rails.logger).to receive(:info).with(/Couldn\'t find Subscription/)
        post :create, params: event_params
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
