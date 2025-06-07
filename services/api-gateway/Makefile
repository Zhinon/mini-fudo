SERVICE=api-gateway

DOCKER_RUN=docker compose run --rm $(SERVICE)

run:
	docker compose up -d

console:
	$(DOCKER_RUN) irb -r ./app.rb

build:
	docker compose build $(SERVICE)

logs:
	docker compose logs -f $(SERVICE)

bash:
	docker compose exec -it $(SERVICE) bash
