# How to run

1. Run rails with docker compose up
  `docker compose up` 
2. If you are runnning it with first time you need run db migration
  `docker compose exec -it web bash`
  `rails db:prepare`
