module Webhooks
  class StripeController < ApplicationController
    rescue_from Subscription::InvalidStatusChanges, with: log_and_respond_no_content
    rescue_from ActiveRecord::RecordInvalid, with: log_and_respond_no_content
    rescue_from ActiveRecord::RecordNotFound, with: log_and_respond_no_content

    def create
      handle_event
    end

    private

    # For POC code purpose let's trust all parameters
    # For production here we should use either Strong Params or Dry Contract
    def event_params
      @event_params ||= params.permit!.to_h
    end

    def object_id
      event_params.dig(:data, :object, :id)
    end

    def subscription_id
      event_params.dig(:data, :object, :subscription)
    end

    def handle_event
      case event_params[:type]
      when 'customer.subscription.created'
        Subscription.create!(subscription_id: object_id)
      when 'customer.subscription.deleted'
        Subscription.find_by!(subscription_id: object_id).canceled!
      when 'invoice.paid'
        Subscription.find_by!(subscription_id: subscription_id).paid!
      else
        Rails.logger.info "Unhandled event type: #{event_params[:type]}"
      end
    end

    def log_and_respond_no_content(error)
      Rails.logger.info(error.message)
      head :no_content
    end
  end
end
