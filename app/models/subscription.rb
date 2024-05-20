class Subscription < ApplicationRecord
  InvalidStatusChanges = Class.new(StandardError)

  enum :status, [:unpaid, :paid, :canceled], _default: :unpaid

  before_update :ensure_expected_status_update

  def ensure_expected_status_update
    raise InvalidStatusChanges, 'trying to cancel non paid subscription' if status == 'canceled' && status_was != "paid"
  end
end
