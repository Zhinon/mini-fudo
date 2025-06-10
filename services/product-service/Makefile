SERVICE=product-service

DOCKER_RUN=docker compose run --rm $(SERVICE)

run:
	docker compose up -d

migrate:
	$(DOCKER_RUN) ruby scripts/migrate.rb

console:
	$(DOCKER_RUN) irb -r ./app.rb

build:
	docker compose build $(SERVICE)

logs:
	docker compose logs -f $(SERVICE)

bash:
	docker compose exec -it $(SERVICE) bash

pworker:
	$(DOCKER_RUN) ruby workers/product_creation_worker.rb

test:
	docker compose run --rm $(SERVICE) bundle exec rspec
