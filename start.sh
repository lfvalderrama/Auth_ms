docker-compose build
docker-compose run --rm auth_ms rails db:create
docker-compose run --rm auth_ms rails db:migrate
docker-compose up
