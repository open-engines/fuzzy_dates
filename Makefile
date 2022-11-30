.PHONY: help synchronize test run-time install uninstall release bump build publish diagrams committer clean remove-all
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

NAME = 'fuzzy_parser'
TITLE = 'Python Parser for Abbreviated Dates'
VENV = venv
PACKAGE_PATH = $(VENV)/bin
PYTHON = $(PACKAGE_PATH)/python3
PIP = $(PACKAGE_PATH)/pip
PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
SYSTEM_PACKAGE_PATH = /usr/bin
PPA_PATH = /etc/apt/sources.list.d
GIT_REPO_URL := $(shell git config --get remote.origin.url)
TOKEN ?= $(shell secret-tool lookup user ${USER} domain pypi.org ) # Overridable

help:  ## Print this help
	@printf '\e[1;34m%s: (%s)\n\n\e[m%s\n------------------------\n' $(NAME) $(TITLE) "Operation    Description"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-12s\033[0m %s\n", $$1, $$2}'

synchronize: $(SYSTEM_PACKAGE_PATH)/git ## Switch to the main branch, fetch changes & delete merged branches
	@git checkout master && git pull && git branch --merged | egrep -v "(^\*|master)" | xargs -r git branch -d || exit 0

test: run-time $(PACKAGE_PATH)/pytest ## Run the test suite
	@$(PYTHON) -m pytest

run-time: system-packages packs ## Install the packages packs required for the development environment
system-packages: $(SYSTEM_PACKAGE_PATH)/swipl $(SYSTEM_PACKAGE_PATH)/git
packs: $(PACK_PATH)/tap  $(PACK_PATH)/date_time $(PACK_PATH)/abbreviated_dates

install: $(PACKAGE_PATH)/$(NAME)  ## Install the latest library release

uninstall: $(PACKAGE_PATH)/$(NAME)   ## Uninstall the library
	@$(PIP) uninstall -y $(NAME)

release: bump build ## Release recipe to be use from Github Actions
	@$(PYTHON) -m twine upload --skip-existing -u "__token__" -p $(TOKEN) dist/*

bump: $(PACKAGE_PATH)/bumpversion ## Increase the version number
	@$(PYTHON) -m bumpversion --allow-dirty --no-commit --no-tag --list patch

build: $(PACKAGE_PATH)/build $(PACKAGE_PATH)/twine  ## Build and check distribution packages
	@$(PYTHON) -m build --sdist --wheel
	@$(PYTHON) -m twine check dist/*

$(PACKAGE_PATH)/%: setup-python
	@$(PYTHON) -m pip install $(notdir $@)
$(VENV)/bin/activate: requirements.txt
	@python3 -m venv $(VENV)
	@$(PIP) install -r requirements.txt

# Targets for Library Language packages
$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

# Targets for Operating System packages
$(SYSTEM_PACKAGE_PATH)/swipl: $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list
	@sudo apt install -y swi-prolog
$(SYSTEM_PACKAGE_PATH)/%: # Install packages from default repo
	@sudo apt install $(notdir $@) -y

# Targets for Operating System repositories
$(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list:
	@sudo add-apt-repository -y ppa:swi-prolog/stable

committer: $(SYSTEM_PACKAGE_PATH)/git
	@git config --local user.email "conrado.rgz@gmail.com" && git config --local user.name "Conrado Rodriguez"