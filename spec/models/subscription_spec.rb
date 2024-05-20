# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'status changes' do
    describe 'valid status changes' do
      context 'when update the status from unpaid to paid' do
        let!(:subscription) { create(:subscription, status: :unpaid) }

        it 'allows changing status' do
          expect do
            subscription.update!(status: :paid)
          end.not_to raise_error
          expect(subscription.status).to eq('paid')
        end
      end

      context 'when update the status from paid to canceled' do
        let!(:subscription) { create(:subscription, status: :paid) }

        it 'allows changing status' do
          expect do
            subscription.update!(status: :canceled)
          end.not_to raise_error
          expect(subscription.status).to eq('canceled')
        end
      end
    end

    describe 'invalid status changes' do
      context 'when trying to change status from unpaid to canceled' do
        let!(:subscription) { create(:subscription, status: :unpaid) }

        it 'will raises an error' do
          expect do
            subscription.update!(status: :canceled)
          end.to raise_error(Subscription::InvalidStatusChanges, 'trying to cancel non paid subscription')
          expect(subscription.reload.status).to eq('unpaid')
        end
      end

      context 'when trying to change status from canceled to unpaid' do
        let(:subscription) { create(:subscription, status: :canceled) }

        it 'will raises an error' do
          expect do
            subscription.update!(status: :unpaid)
          end.to raise_error(Subscription::InvalidStatusChanges, 'already canceled subscription')
          expect(subscription.reload.status).to eq('canceled')
        end
      end

      context 'when trying to change status from canceled to paid' do
        let(:subscription) { create(:subscription, status: :canceled) }

        it 'will raises an error' do
          expect do
            subscription.update!(status: :paid)
          end.to raise_error(Subscription::InvalidStatusChanges, 'already canceled subscription')
          expect(subscription.reload.status).to eq('canceled')
        end
      end
    end
  end
end
