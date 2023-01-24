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

release: build ## Release recipe to be use from Github Actions
	@$(PYTHON) -m twine upload --skip-existing -u "__token__" -p $(TOKEN) dist/*

bump: $(PYTHON_PATH)/bumpversion ## Increase the version number
	@$(PYTHON) -m bumpversion --allow-dirty --no-commit --no-tag --list patch

build: $(PYTHON_PATH)/build $(PYTHON_PATH)/twine  ## Build and check distribution packages
	@$(PYTHON) -m build --sdist --wheel
	@$(PYTHON) -m twine check dist/*


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

/usr/bin/%: # Install packages from default repo
	@apt-get -qqy install $(notdir $@) -y

/etc/apt/sources.list.d/swi-prolog-ubuntu-stable-$(DISTRIBUTION_CODENAME).list:
	apt-add-repository -y ppa:swi-prolog/stable

#
# Python virtual environment
#
$(VENV)/bin/activate: requirements.txt
	test -d $(VENV) || python3 -m venv $(VENV)
	@$(PYTHON) -m pip install --upgrade pip
	@$(PYTHON) -m pip install --use-pep517 -r requirements.txt
	@touch $@

$(PYTHON_PATH)/%: $(VENV)/bin/activate # Install packages from default repo
	@$(PYTHON) -m pip install $(notdir $@)

#
# prolog packs
#
.PHONY: packs
PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
packs: $(PACK_PATH)/tap  $(PACK_PATH)/date_time $(PACK_PATH)/abbreviated_dates
$(PACK_PATH)/%: # Targets for prolog packages
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

#
# clean
#
.PHONY:	clean
clean: ## Remove build files
	@python3 setup.py clean --all
	@rm -rfd fuzzy_parser.egg-info/ dist/ __pycache__
	@swipl -g "(member(P,[abbreviated_dates,date_time,tap]),pack_property(P,library(P)),pack_remove(P),fail);true,halt"


.PHONY:	clean-more
clean-more: clean /usr/bin/swipl ## Remove packages and packs
	@rm -rfd $(VENV)
	@apt-get --purge -qqy autoremove swi-prolog-nox
	@add-apt-repository -yr ppa:swi-prolog/stable
	@rm -f /etc/apt/sources.list.d/swi-prolog-ubuntu-stable-$(DISTRIBUTION_CODENAME).list


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
