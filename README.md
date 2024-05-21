# How to Run

1. Start the Rails application with Docker Compose:
   ```sh
   docker compose up
   ```
2. If this is your first time running the application, you need to run the database migration:
   ```sh
   docker compose exec -it web bash
   rails db:prepare
   ```

# About This Project

This project is a Proof of Concept (POC) for handling Stripe subscription webhooks.

There are several areas that can be improved if needed:
1. Event object serialization using the [Stripe gem](https://github.com/stripe/stripe-ruby).
2. Creating a service layer for separated event handlers.
3. Implementing strong parameters for strict event object validation.
4. Since events can be received simultaneously by different threads, use `with_lock` to avoid race conditions, or utilize the [`idempotency_key`](https://docs.stripe.com/api/idempotent_requests) to ensure idempotency.

# Further consideration

1. Stripe allows to cancel subscription that has state `upaid` (subscription no paid invoice).
2. Test case can be improved more corner cases like invalid structure of request params