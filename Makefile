.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

DOCKER=docker-compose --file docker/docker-compose.yaml
TEST_PARAMS=

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## check style with flake8
	flake8 sqlalchemy_heavyai tests

test: ## run tests quickly with the default Python
	pytest


# report available at htmlcov/index.html
coverage: ## check code coverage quickly with the default Python
	coverage run --source sqlalchemy_heavyai -m pytest
	coverage report -m
	coverage html

docs: ## generate documentation
	rm -rf docs/_build/*
	python docs/patch.py
	jupyter-book build docs/

install: clean ## install the package to the active Python's site-packages
	python -m pip install .

develop: clean ## install the package in development mode
	python -m pip install -e '.[dev]'
	pre-commit install

# apache superset
docker-superset-build:
	$(DOCKER) build superset

docker-superset-start: docker-superset-build
	$(DOCKER) up -d --renew-anon-volumes --force-recreate superset
	@sleep 5
	$(DOCKER) exec superset bash /opt/sqlalchemy-heavyai/docker/setup-superset.sh
	$(DOCKER) logs -f superset

docker-superset-bash:
	$(DOCKER) exec superset bash

# heavydb
docker-heavydb-build:
	$(DOCKER) pull heavydb

docker-heavydb-start:
	$(DOCKER) up -d heavydb
	$(DOCKER) logs -f --tail=100 heavydb

docker-heavydb-bash:
	$(DOCKER) exec heavydb bash


# tests

run-tests:
	pytest -vv -s ${TEST_PARAMS} tests/
