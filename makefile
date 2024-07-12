# Makefile for Django projects
#
# Usage:
# make build - run all the commands below
# make pip_compile - compile the requirements using pip-compile
# make pip_install - install the requirements using pip
# make python_lint - run flake8
# make python_format - run black
# make python_isort - run isort
# make sass_compile - compile the sass files
# make webpack_compile - compile the webpack files
#
# Not part of the build process:
# make image_dev - build the dev container
# make image_prod - build the prod container
#
# Useful resources:
# https://earthly.dev/blog/python-makefile/

# Variables

# check that .env file exists and then load it
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

DOCKER_TAG ?= dev
COMPOSE_FILE ?= compose.yml
IMAGE_NAME ?= djangocms-app
REQUIREMENTS_IN ?= requirements.in
REQUIREMENTS_FILE ?= requirements.txt
BUILD_FOLDER ?= ./build/reports
BUILD_DATE := $(shell date +'%Y-%m-%d %H:%M:%S')

SASS_SOURCE_DIR ?= main/src

# This will find all the .scss files in the SASS_SOURCE_DIR and its subdirectories
# SASS_SOURCES := $(wildcard $(SASS_SOURCE_DIR)/**/*.scss)

SASS_SOURCES := $(shell find $(SASS_SOURCE_DIR) -name '*.scss')

# Find all the .scss files in library/src/scss and its subdirectories
# SASS_SOURCES2 := $(wildcard $(SASS_SOURCE_DIR)/**/*.scss)

JS_SOURCE_DIR ?= main/src/js
JS_SOURCES := $(wildcard $(JS_SOURCE_DIR)/**/*.js)

SSH_KEY ?= ~/.ssh/id_rsa

VENV_NAME ?= .venv
PYTHON_ENV_PATH := $(or $(VIRTUAL_ENV), $(VENV_NAME))

# Targets
.PHONY: pip_compile pip_install python_lint python_format python_isort \
sass_compile webpack_compile image_dev image_prod docker_up docker_down

# Default build command
build: pip_compile \
pip_install \
python_format \
python_lint \
sass_compile \
webpack_compile

# This function, named fn_pip_compile, is used to install pip-tools and generate
# a requirements file.
#
# It takes no arguments.
define fn_pip_compile
	@$(PYTHON_ENV_PATH)/bin/pip install --quiet pip-tools
	@$(PYTHON_ENV_PATH)/bin/pip-compile --strip-extras --output-file=$(REQUIREMENTS_FILE) $(REQUIREMENTS_IN)
endef

# Compile projects requirements using pip-compile
requirements.txt: $(REQUIREMENTS_IN)
	$(call fn_pip_compile)

# Alias for pip_compile
pip_compile: pip_env $(REQUIREMENTS_IN)
	$(call fn_pip_compile)

pip_env:
	# check if PYTHON_ENV = $(VENV_NAME) and if it is then check whether the directory exists
	@-echo "PYTHON_ENV is set to $(PYTHON_ENV_PATH)";
	@-if [ "$(PYTHON_ENV_PATH)" = $(VENV_NAME) ]; then \
		if [ ! -d "$(PYTHON_ENV_PATH)" ]; then \
			echo "Virtual environment created."; \
			python3 -m venv $(VENV_NAME) && $(VENV_NAME)/bin/pip install --upgrade pip; \
		fi; \
	fi

pip_install: pip_env pip_compile $(REQUIREMENTS_FILE)
	@$(PYTHON_ENV_PATH)/bin/pip install -r $(REQUIREMENTS_FILE)
	@echo "$(BUILD_DATE): pip install -r $(REQUIREMENTS_FILE)" >> $(BUILD_FOLDER)/build.log

python_lint: pip_env
	@$(PYTHON_ENV_PATH)/bin/pip install --quiet flake8
	@$(PYTHON_ENV_PATH)/bin/flake8 . --ignore=E501 --exclude=./node_modules/*,**/migrations/*,$(VENV_NAME)/; exit 0;
	@echo "$(BUILD_DATE): flake8 . --ignore=E501 --exclude=./node_modules/*,**/migrations/*" >> $(BUILD_FOLDER)/build.log

python_format: pip_env
	@$(PYTHON_ENV_PATH)/bin/pip install --quiet black
	@$(PYTHON_ENV_PATH)/bin/black . --exclude="/migrations/|env/"
	@echo "$(BUILD_DATE): black . --exclude=\"/migrations/\"" >> $(BUILD_FOLDER)/build.log

python_isort:
	@$(PYTHON_ENV_PATH)/bin/pip install --quiet isort
	@-$(PYTHON_ENV_PATH)/bin/isort . --skip-glob "*/migrations/*" --skip /node_modules/ --skip $(VENV_NAME)/ --profile black
	@echo "python_isort complete"

npm_install: package.json
	@npm install

define fn_sass_compile
	@npm run sass-build > $(BUILD_FOLDER)/sass.txt 2>&1; exit 0;
	@echo "$(BUILD_DATE): npm run sass-build"
	@echo "sass_compile complete"
endef

# this should be dependent on changes within any sass file under oro/src/sass
sass: npm_install $(SASS_SOURCES)
	$(call fn_sass_compile)

library/static/css/theme.css: npm_install $(SASS_SOURCES)
	$(call fn_sass_compile)

define fn_webpack_compile
	@npm run webpack-prod > $(BUILD_FOLDER)/webpack.txt 2>&1; exit 0;
	@echo "$(BUILD_DATE): npm run webpack-prod" >> $(BUILD_FOLDER)/build.log
endef

js: npm_install
	$(call fn_webpack_compile)

library/static/js/index.js: npm_install
	$(call fn_webpack_compile)

image:
	@docker build -t $(IMAGE_NAME):$(DOCKER_TAG) . --target $(DOCKER_TAG)

clean:
	@rm -rf $(BUILD_FOLDER)/*
	@rm -rf $(VENV_NAME)
	@echo "clean complete"

check_me:
	@echo "SASS_SOURCE_DIR: $(SASS_SOURCE_DIR)"
	@echo "SASS_SOURCES: $(SASS_SOURCES)"
	@echo "SSH_KEY: $(SSH_KEY)"

docker_up:
	@docker compose -f "$(COMPOSE_FILE)" up -d --build

docker_down:
	@docker compose -f "$(COMPOSE_FILE)" down

docker_prod_test:
	# run prod image and run tests on it
	@docker run -it library:prod python manage.py test

docker_flake:
	# run prod image and run tests on it
	docker run -it library:dev flake8 . --ignore=E501 --exclude=./node_modules/*,**/migrations/*,$(VENV_NAME)/; exit 0;
