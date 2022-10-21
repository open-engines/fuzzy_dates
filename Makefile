.PHONY: help synchronize install uninstall release test bump build publish diagrams committer clean remove-all
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

NAME = 'fuzzy_dates'
TITLE = 'Python Parser for Abbreviated Dates'

VENV = venv
PACKAGE_PATH = $(VENV)/bin
PYTHON = $(PACKAGE_PATH)/python3
PIP = $(PACKAGE_PATH)/pip

PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
SYSTEM_PACKAGE_PATH = /usr/bin
PPA_PATH = /etc/apt/sources.list.d

TWINE_PASSWORD ?= $(shell secret-tool lookup user ${USER} domain pypi.org )

help:  ## Print this help
	@printf '\e[1;34m\n%s\e[m\n\n' "List of available commands:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-12s\033[0m %s\n", $$1, $$2}'

synchronize: $(SYSTEM_PACKAGE_PATH)/git ## Switch to the main branch, fetch changes & delete merged branches
	@git checkout master && git pull && git branch --merged | egrep -v "(^\*|master)" | xargs -r git branch -d || exit 0


release: bump build ## Release recipe to be use from Github Actions
	@$(PYTHON) -m twine upload --skip-existing -u "__token__" -p $(TWINE_PASSWORD) dist/*

test: $(PACKAGE_PATH)/pytest ## Run the test suite
	@$(PYTHON) -m pytest

bump: $(PACKAGE_PATH)/bumpversion ## Increase the version number
	@$(PYTHON) -m bumpversion --allow-dirty --no-commit --no-tag --list patch

build: $(PACKAGE_PATH)/setuptools-rust $(PACKAGE_PATH)/build
	@$(PYTHON) -m build --sdist --wheel
	@$(PYTHON) -m twine --version
	@$(PYTHON) -m twine check dist/*

$(VENV)/bin/activate: requirements requirements.txt
	@python3 -m venv $(VENV)
	@$(PIP) install -r requirements.txt

requirements: system-packages packs ## Install the packages packs required for the development environment
system-packages: $(SYSTEM_PACKAGE_PATH)/swipl $(SYSTEM_PACKAGE_PATH)/swipl $(SYSTEM_PACKAGE_PATH)/git
packages: $(PACKAGE_PATH)/pyswip
packs: $(PACK_PATH)/tap  $(PACK_PATH)/date_time $(PACK_PATH)/abbreviated_dates

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

clean:  ## Remove debris
	@python3 setup.py clean --all
	@rm -rfd fuzzy_parser.egg-info/ dist/
	@rm -rf __pycache__ $(VENV)

remove-all: $(SYSTEM_PACKAGE_PATH)/swipl ## Remove packages and packs
	@swipl -g "(member(P,[cli_table,abbreviated_dates,date_time,tap]),pack_property(P,library(P)),pack_remove(P),fail);true,halt"
	@pip3 uninstall -y bumpversion twine
	@sudo sudo apt-get --purge -y autoremove swi-prolog bumpversion
	@sudo add-apt-repository --remove -y ppa:swi-prolog/stable
	@sudo rm -f $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list

$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

$(PACKAGE_PATH)/%: $(VENV)/bin/activate # Install packages from default repo
	@$(PYTHON) -m pip install $(notdir $@)
$(SYSTEM_PACKAGE_PATH)/swipl: $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list
	@sudo apt install -y swi-prolog
$(SYSTEM_PACKAGE_PATH)/%: # Install packages from default repo
	@sudo apt install $(notdir $@) -y
$(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list:
	@sudo add-apt-repository -y ppa:swi-prolog/stable