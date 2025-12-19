#BUILD_PATH=/var/www/laravel-rc# Production Linux
BUILD_PATH=/home/$(USER)/laravel-rc# Linux
#BUILD_PATH=/Users/$(USER)/laravel-rc# Apple

#COMPOSE_FILE=docker-compose.yml# Production Linux
COMPOSE_FILE=docker-compose-dev.yml# Linux
#COMPOSE_FILE=docker-compose-dev-apple.yml# Apple

BUILD_VERSION = master

# Определение операционной системы
UNAME_S := $(shell uname -s)

# TODO: make first-run prod
first-run:
	if [ ! -f "$(BUILD_PATH)/app/.env" ]; then \
		make copy-example-env; \
	fi
	if [ ! -f "$(BUILD_PATH)/app/.rr.yaml" ]; then \
		make copy-rr-example; \
	fi
	make rebuild-nocache
	make run
	make build-app
	make laravel-key-generate
	make restart

rebuild:
	docker compose --env-file $(BUILD_PATH)/app/.env -f $(COMPOSE_FILE) build

rebuild-nocache:
	docker compose --env-file $(BUILD_PATH)/app/.env -f $(COMPOSE_FILE) build --no-cache

rebuild-restart:
	make rebuild
	make stop
	make run

run:
	docker compose --env-file $(BUILD_PATH)/app/.env -f $(COMPOSE_FILE) up -d

recreate:
	docker compose --env-file $(BUILD_PATH)/app/.env -f $(COMPOSE_FILE) up -d --force-recreate

stop:
	docker compose --env-file $(BUILD_PATH)/app/.env -f $(COMPOSE_FILE) down

restart:
	make stop
	make run

build-app:
	docker exec laravel-rc bash -c "composer install"

build-app-prod:
	docker exec laravel-rc bash -c "composer install --no-dev --optimize-autoloader"

rr-supervisor-start:
	docker exec laravel-rc bash -c "supervisorctl start rr-server:*"

rr-supervisor-stop:
	docker exec laravel-rc bash -c "supervisorctl stop rr-server:*"

laravel-key-generate:
	docker exec laravel-rc bash -c "php artisan key:generate"

composer-du:
	docker exec laravel-rc bash -c "composer du"

rr-workers:
	docker exec -i laravel-rc sh -c "rr workers"

rr-reset:
	docker exec -i laravel-rc sh -c "rr reset"

copy-example-env:
	cp $(BUILD_PATH)/app/.env.example $(BUILD_PATH)/app/.env

copy-rr-example:
	cp $(BUILD_PATH)/app/.rr.example.yaml $(BUILD_PATH)/app/.rr.yaml