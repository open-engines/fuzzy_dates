.PHONY: help synchronize install uninstall release test bump build publish diagrams committer clean remove-all
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

NAME = 'fuzzy_dates'
TITLE = 'Python Parser for Abbreviated Dates'
PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
PACKAGE_PATH = ${USER}/.local/bin
SYSTEM_PACKAGE_PATH = /usr/bin
PPA_PATH = /etc/apt/sources.list.d

help:  ## Print this help
	@printf '\e[1;34m\n%s\e[m\n\n' "List of available commands:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-12s\033[0m %s\n", $$1, $$2}'

synchronize: $(SYSTEM_PACKAGE_PATH)/git ## Switch to the main branch, fetch changes & delete merged branches
	@git checkout master && git pull && git branch --merged | egrep -v "(^\*|master)" | xargs -r git branch -d || exit 0

install: requirements $(PACKAGE_PATH)/fuzzy_parser ## Install the latest library release

uninstall:
	@pip3 uninstall -y fuzzy_parser

requirements: packages packs  ## Install the packages packs required for the development environment
packages: $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list $(SYSTEM_PACKAGE_PATH)/swipl $(SYSTEM_PACKAGE_PATH)/git
packs: $(PACK_PATH)/tap  $(PACK_PATH)/date_time $(PACK_PATH)/abbreviated_dates

release: $(PACKAGE_PATH)/twine test uninstall bump build ## Release recipe to be use from Github Actions
	@twine upload --skip-existing --repository testpypi dist/*
	@twine upload --skip-existing dist/*

test: $(PACKAGE_PATH)/pytest  ## Run the test suite
	@pytest

bump: $(PACKAGE_PATH)/bumpversion ## Increase the version number
	@bumpversion --allow-dirty --no-commit --no-tag --list patch

build: $(PACKAGE_PATH)/twine
	@python3 setup.py sdist bdist_wheel
	@twine check dist/*

GIT_REPO_URL := $(shell git config --get remote.origin.url)

publish: diagrams ## Publish the diagrams
	@echo $(GIT_REPO_URL) \
	&& cd target/publish \
	&& git init . \
	&& git remote add github ${GIT_REPO_URL} \
	&& git checkout -b gh-pages \
	&& git add . \
	&& git commit -am "Static site deploy" \
	&& git push github gh-pages --force \
	&& cd ../.. || exit

diagrams: workflow

#
#  workflow
#
workflow: target/publish/workflow.svg  ## Creates the Diagrams
target/publish/workflow.svg: $(SYSTEM_PACKAGE_PATH)/mvn
	@printf '\e[1;34m%-6s\e[m\n' "Start generation of scalable C4 Diagrams"
	@mvn exec:java@generate-diagrams -f .github/plantuml/
	@printf '\n\e[1;34m%-6s\e[m\n' "Start generation of portable C4 Diagrams"
	@mvn exec:java@generate-diagrams -DoutputType=png -Dlinks=0  -f .github/plantuml/
	@printf '\n\e[1;34m%-6s\e[m\n' "The diagrams has been generated"

committer: $(SYSTEM_PACKAGE_PATH)/git
	@git config --local user.email "conrado.rgz@gmail.com" && git config --local user.name "Conrado Rodriguez"

clean: ## Remove debris
	@rm -rfd target

remove-all: uninstall $(SYSTEM_PACKAGE_PATH)/swipl ## Remove packages and packs
	@swipl -g "(member(P,[cli_table,abbreviated_dates,date_time,tap]),pack_property(P,library(P)),pack_remove(P),fail);true,halt"
	@pip3 uninstall -y bumpversion twine
	@sudo sudo apt-get --purge -y autoremove swi-prolog bumpversion
	@sudo add-apt-repository --remove -y ppa:swi-prolog/stable
	@sudo rm -f $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list

$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

$(PACKAGE_PATH)/%: # Install packages from default repo
	@pip3 install $(notdir $@)

$(SYSTEM_PACKAGE_PATH)/swipl:
	@sudo apt install -y swi-prolog
$(SYSTEM_PACKAGE_PATH)/%: # Install packages from default repo
	@sudo apt install $(notdir $@) -y

$(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list:
	@sudo add-apt-repository -y ppa:swi-prolog/stable