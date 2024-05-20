# How to run

1. Run rails with docker compose up
  `docker compose up` 
2. If you are runnning it with first time you need run db migration
  `docker compose exec -it web bash`
  `rails db:prepare`

# What about this project

This project is POC for Stripe subscription webhook.

There are lot of things can be improved if required.
1. Event object serializer from [Stripe gem](https://github.com/stripe/stripe-ruby)
2. Service layer for separated event handlers.
3. Strong parameters for strict event object validations.
4. Usually events could be received at same time with different threads. 
   To avoid race condtion `with_lock` can be used.
   Or [`idempotency_key` ](https://docs.stripe.com/api/idempotent_requests)