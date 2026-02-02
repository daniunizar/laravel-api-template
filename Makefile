## Variables
PROJ_ENV = local
DOCKER_DIR := docker/$(PROJ_ENV)
include $(DOCKER_DIR)/.env
APP_IMGS := $(shell docker images -q --filter label=custom.project=$(PROJECT_NAME) --format "{{.ID}}")
DOCKER_COMPOSE = docker compose -f ./docker/${PROJ_ENV}/docker-compose.yml
PROJ_CONF_SCRIPT = app_configuration

##
## Global functions
##

.DELETE_ON_ERROR:

help:
	@echo '																														'
	@echo 'Makefile for managing the application																				'
	@echo '																														'
	@echo 'Usage:																												'
	@echo '   make					Print help																					'
	@echo '   make help				Print help																					'
	@echo '   make build-hard			Build the environment from scratch and remove everything if exist						'
	@echo '   make build-soft			Build the environment from scratch and keep Mysql volumes if exist		'
	@echo '   make urls				Print the application URLs																	'
	@echo '   make start				Start the application																	'
	@echo '   make stop                    	Stop the application																'
	@echo '   make status                  	Display the status of the containers												'
	@echo '   make destroy				Delete the environment																	'
	@echo '   make reset				Delete the environment but keeps the Mysql volumes						'
	@echo '   make logs-php			Display the PHP container logs																'
	@echo '   make logs-web			Display the Web server container logs														'
	@echo '   make logs-laravel			Display the Laravel logs																'
	@echo '   make logs-db				Display the database container logs														'
	@echo '   make ssh-php                 	Connect to the PHP container            											'
	@echo '   make ssh-web                 	Connect to the Web server container     											'
	@echo '   make ssh-db                  	Connect to the database container       											'
	@echo '   make cache                    	Clean application cache                  										'
	@echo '   make permissions              	Set the permissions of the application  										'
	@echo '   make update                  	Update the application                  											'
	@echo '   make db-refresh              	Reset the database to default           											'
	@echo '   make db-run-migrations       	Run database migrations                 											'
	@echo '   make tests                   	Run the tests                           											'
	@echo '   make linter-cs-check			Run PHP CS Fixer to analyze the code	 	                    					'
	@echo '   make linter-cs-check-debug		Run PHP CS Fixer in debug mode to analyze the code         						'
	@echo '   make linter-cs-fix			Run PHP CS Fixer to fix the suggestions			 	            					'
	@echo '   make phpstan				Run PHPstan 													    					'
	@echo '   make all-checks			Run all linters and static analysis						    							'


build-hard:
ifeq (,$(wildcard .env))
	@echo 'The configuration file ".env" does not exist. Please, create it following the README instructions.'
	@exit 1
endif

ifeq (,$(wildcard .env.testing))
	@echo 'The configuration file ".env.testing" does not exist. Please, create it following the README instructions.'
	@exit 1
endif

	@$(MAKE) destroy

	@${DOCKER_COMPOSE} build --no-cache
	@${MAKE} start

	@sleep 30

	@docker exec -t $(PHP_CONTAINER_NAME) bash ${DOCKER_DIR}/${PROJ_CONF_SCRIPT} fresh
	@$(MAKE) tests

	@$(MAKE) urls


build-soft:
ifeq (,$(wildcard .env))
	@echo 'The configuration file ".env" does not exist. Please, create it following the README instructions.'
	@exit 1
endif

ifeq (,$(wildcard .env.testing))
	@echo 'The configuration file ".env.testing" does not exist. Please, create it following the README instructions.'
	@exit 1
endif

	@$(MAKE) reset

	@${DOCKER_COMPOSE} build --no-cache
	@${MAKE} start

	@docker exec -t $(PHP_CONTAINER_NAME) bash ${DOCKER_DIR}/${PROJ_CONF_SCRIPT} update
	@$(MAKE) tests

	@$(MAKE) urls


urls:
	@echo "\nYou might add the following entry in the configuration file /etc/hosts"
	@echo "   127.0.0.1 $(PROJ_DOMAIN)"
	@echo ""
	@echo "The available URLs are:"
	@echo "   http://localhost:$(NGINX_HOST_HTTP_PORT)"
	@echo "   https://localhost:$(NGINX_HOST_HTTPS_PORT)"
	@echo "   http://$(PROJ_DOMAIN):$(NGINX_HOST_HTTP_PORT)"
	@echo "   https://$(PROJ_DOMAIN):$(NGINX_HOST_HTTPS_PORT)"
	@echo ""


start:
	@${DOCKER_COMPOSE} up -d
	@$(MAKE) urls


stop:
	@${DOCKER_COMPOSE} stop


status:
	@${DOCKER_COMPOSE} ps


destroy:
	@${DOCKER_COMPOSE} down -v -t 20 2>/dev/null

ifneq ($(strip $(APP_IMGS)),)
	@docker rmi -f $(APP_IMGS) 2>/dev/null
endif

	@echo ""
	@sudo rm -rf vendor/


reset:
	@${DOCKER_COMPOSE} down -t 20 2>/dev/null

ifneq ($(strip $(APP_IMGS)),)
	@docker rmi -f $(APP_IMGS) 2>/dev/null
endif

	@echo "\nThe environment was removed, however, the 'vendor' directory is still present."


logs-php:
	@docker logs $(PHP_CONTAINER_NAME)


logs-web:
	@docker logs $(NGINX_CONTAINER_NAME)


logs-laravel:
	@docker exec -ti $(PHP_CONTAINER_NAME) cat storage/logs/laravel.log


logs-db:
	@docker logs $(MYSQL_CONTAINER_NAME)


ssh-php:
	@docker exec -ti $(PHP_CONTAINER_NAME) bash


ssh-web:
	@docker exec -ti $(NGINX_CONTAINER_NAME) sh


ssh-db:
	@docker exec -ti $(MYSQL_CONTAINER_NAME) bash


cache:
	@docker exec -t $(PHP_CONTAINER_NAME) bash docker/${PROJ_ENV}/${PROJ_CONF_SCRIPT} cache


db-refresh:
	@docker exec -t $(PHP_CONTAINER_NAME) php artisan migrate:fresh --seed --force


db-run-migrations:
	@docker exec -t $(PHP_CONTAINER_NAME) php artisan migrate  --force


permissions:
	@docker exec -t $(PHP_CONTAINER_NAME) bash docker/${PROJ_ENV}/${PROJ_CONF_SCRIPT} permissions


update:
	@docker exec -t $(PHP_CONTAINER_NAME) bash docker/${PROJ_ENV}/${PROJ_CONF_SCRIPT} update


tests:
	@echo "---------\nRunning Laravel tests...\n----------\n"
	@docker exec -t $(PHP_CONTAINER_NAME) php artisan test


linter-cs-check:
	@echo "--------\nRunning PHP CS FIXER...\n--------\n"
	@docker exec -t $(PHP_CONTAINER_NAME) composer run linter-cs-check


linter-cs-check-debug:
	@echo "--------\nRunning PHP CS FIXER (DEBUG)...\n--------\n"
	@docker exec -t $(PHP_CONTAINER_NAME) composer run linter-cs-check-debug


linter-cs-fix:
	@echo "--------\nRunning PHP CS FIXER...\n--------\n"
	@docker exec -t $(PHP_CONTAINER_NAME) composer run linter-cs-fix


phpstan:
	@echo "--------\nRunning PHPStan...\n--------\n"
	@docker exec -t $(PHP_CONTAINER_NAME) composer run phpstan


all-checks:
	@echo "---------\nChecking all checks at onces...\n----------\n"
	@$(MAKE) tests
	@$(MAKE) linter-cs-check
	@$(MAKE) phpstan


.PHONY: help build-hard build-soft urls start stop status destroy reset logs-php logs-web logs-laravel logs-db cache permissions update ssh-php ssh-web ssh-db db-refresh db-run-migrations tests linter-cs-check linter-cs-fix all-checks