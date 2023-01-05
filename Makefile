SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

NAME = 'fuzzy_parser'
TITLE = 'Python Parser for Abbreviated Dates'
TOKEN ?= $(shell secret-tool lookup user ${USER} domain pypi.org ) # Overridable

all: help
help:  ## Print this help
	@printf '\e[1;34m%s: (%s)\n\n\e[m%s\n------------------------\n' $(NAME) $(TITLE) "Operation    Description"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-12s\033[0m %s\n", $$1, $$2}'

synchronize: /usr/bin/git ## Switch to the main branch, fetch changes & delete merged branches
	@git checkout master && git pull && git branch --merged | egrep -v "(^\*|master)" | xargs -r git branch -d || exit 0

.PHONY: test
VENV = venv
PYTHON_PATH = $(VENV)/bin
PYTHON = $(PYTHON_PATH)/python3
test: $(PYTHON_PATH)/pytest install ## Run the test suite
	@$(PYTHON) -m pytest

#
# install
#
.PHONY: install
PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
install: $(PACK_PATH)/tap $(PACK_PATH)/date_time   ## Install the latest library release
	@: $${VERSION:=$$(curl --silent 'https://api.github.com/repos/crgz/abbreviated_dates/releases/latest'|jq -r .tag_name)} ;\
	REMOTE=https://github.com/crgz/abbreviated_dates/archive/$$VERSION.zip ;\
	swipl -qg "pack_remove(abbreviated_dates),pack_install('$$REMOTE',[interactive(false)]),halt(0)" -t 'halt(1)'
$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

uninstall: $(PYTHON_PATH)/$(NAME)   ## Uninstall the library
	@$(PIP) uninstall -y $(NAME)

release: bump build ## Release recipe to be use from Github Actions
	@$(PYTHON) -m twine upload --skip-existing -u "__token__" -p $(TOKEN) dist/*

bump: $(PYTHON_PATH)/bumpversion ## Increase the version number
	@$(PYTHON) -m bumpversion --allow-dirty --no-commit --no-tag --list patch

build: $(PYTHON_PATH)/build $(PYTHON_PATH)/twine  ## Build and check distribution packages
	@$(PYTHON) -m build --sdist --wheel
	@$(PYTHON) -m twine check dist/*

$(PACKAGE_PATH)/%: setup-python
	@$(PYTHON) -m pip install $(notdir $@)

#
# virtual-environment
#
.PHONY:	setup-python
setup-python: $(VENV)/bin/activate ## Setup python virtual environment
$(VENV)/bin/activate: requirements.txt
	test -d $(VENV) || python3.11 -m venv $(VENV)
	@$(PIP) install --upgrade pip
	@$(PIP) install -r requirements.txt
	@touch $@

#
# utilities
#
DISTRIBUTION_CODENAME := $(shell awk -F'=' '/UBUNTU_CODENAME/{print $$2}' /etc/os-release)
SUPPORTED_DISTRIBUTIONS := focal jammy
ifeq ($(filter $(DISTRIBUTION_CODENAME),$(SUPPORTED_DISTRIBUTIONS)),)
    $(warning Terminating on detection of unsupported Ubuntu distribution: $(DISTRIBUTION_CODENAME). \
    Supported distibutions are: $(SUPPORTED_DISTRIBUTIONS))
endif

.PHONY: utilities
utilities: system-packages /usr/bin/swipl /usr/bin/python

.PHONY: system-packages
system-packages:
	sudo apt-get update
	apt-get -qqy install git build-essential software-properties-common jq

/usr/bin/swipl: /etc/apt/sources.list.d/swi-prolog-ubuntu-stable-$(DISTRIBUTION_CODENAME).list
	@apt-get -qqy install swi-prolog-nox

# Targets for packages
$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

.PHONY:	prolog-purge
prolog-purge: ## Warning! Remove prolog programming language
	@apt-get --purge -y autoremove swi-prolog-nox # Purge the list file as well


#
# remove
#
remove-all: clean  /usr/bin/swipl ## Remove packages and packs
	@rm -rfd $(VENV)
	@swipl -g "(member(P,[cli_table,abbreviated_dates,date_time,tap]),pack_property(P,library(P)),pack_remove(P),fail);true,halt"
	@sudo sudo apt-get --purge -y autoremove swi-prolog
	@sudo add-apt-repository --remove -y ppa:swi-prolog/stable
	@sudo rm -f $(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list

clean: ## Remove build files
	@python3 setup.py clean --all
	@rm -rfd fuzzy_parser.egg-info/ dist/ __pycache__

# Targets for Operating System packages

 /usr/bin/%: # Install packages from default repo
	@apt install $(notdir $@) -y

#
# Debug
#
.PHONY:	debug
debug: ## Display local make variables defined
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic,\
			$(origin $V)), \
			$(warning $V = $($V) )) \
	)

.PHONY:	debug-all
debug-all: ## Display all make variables defined
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(warning $V = $($V) ) \
	)

committer:  /usr/bin/git
	@git config --local user.email "conrado.rgz@gmail.com" && git config --local user.name "Conrado Rodriguez"