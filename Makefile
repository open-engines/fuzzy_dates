SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

NAME = 'fuzzy_parser'
TITLE = 'Python Parser for Abbreviated Dates'
VENV = venv
PACKAGE_PATH = $(VENV)/bin
PYTHON = $(PACKAGE_PATH)/python3
PIP = $(PACKAGE_PATH)/pip
PACK_PATH = ${HOME}/.local/share/swi-prolog/pack
PPA_PATH = /etc/apt/sources.list.d
GIT_REPO_URL := $(shell git config --get remote.origin.url)
TOKEN ?= $(shell secret-tool lookup user ${USER} domain pypi.org ) # Overridable

all: help
help:  ## Print this help
	@printf '\e[1;34m%s: (%s)\n\n\e[m%s\n------------------------\n' $(NAME) $(TITLE) "Operation    Description"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-12s\033[0m %s\n", $$1, $$2}'

test: ## Run the test suite
	$(MAKE) setup-python
	sudo $(MAKE) setup-prolog
	$(MAKE) packs
	@$(PYTHON) -m pytest

system-packages: /usr/bin/swipl  /usr/bin/git
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

.PHONY:	setup-prolog-8
DISTRIBUTION_CODENAME := $(shell lsb_release -sc )
SUPPORTED_DISTRIBUTIONS := focal bionic
ifeq ($(filter $(DISTRIBUTION_CODENAME),$(SUPPORTED_DISTRIBUTIONS)),)
    $(warning Terminating on detection of unsupported Ubuntu distribution: $(DISTRIBUTION_CODENAME). \
    Supported distibutions are: $(SUPPORTED_DISTRIBUTIONS))
endif
OK = '\e[1;34m[ Ok ]\e[m '
FAIL = '\e[1;34m[Fail]\e[m '
setup-prolog-8: prolog-purge /tmp/$(DISTRIBUTION_CODENAME).deb
	@add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(DISTRIBUTION_CODENAME) main universe restricted multiverse"
	@apt install -y /tmp/$(DISTRIBUTION_CODENAME).deb dctrl-tools # dctrl-tools provides grep-aptavail
	@dpkg --verify swi-prolog-nox 2>/dev/null ; if [ $$? -eq 0 ]; then printf $(OK); else printf $(FAIL); fi
	@grep-aptavail -PX swi-prolog-nox -s Description | cut -d' ' -f2-
	@touch $@

SWI_PROLOG_URL = 'https://launchpad.net/~swi-prolog/+archive/ubuntu/stable/+build'
/tmp/focal.deb:
	@wget -q --no-verbose $(SWI_PROLOG_URL)/24099974/+files/swi-prolog-nox_8.4.3-1-g10c53c6e3-focalppa2_amd64.deb -O $@
/tmp/bionic.deb:
	@wget -q --no-verbose $(SWI_PROLOG_URL)/24099913/+files/swi-prolog-nox_8.4.3-0-bionicppa2_amd64.deb -O $@

setup-prolog-9: prolog-purge $(PPA_PATH)/swi-prolog-ubuntu-stable-%.list
	@apt install -y swi-prolog

$(PPA_PATH)/swi-prolog-ubuntu-stable-%.list:
	@add-apt-repository -y ppa:swi-prolog/stable

# Targets for packages
$(PACK_PATH)/%:
	@swipl -qg "pack_install('$(notdir $@)',[interactive(false)]),halt"

# Targets for Operating System packages

 /usr/bin/%: # Install packages from default repo
	@apt install $(notdir $@) -y

# Targets for Operating System repositories
$(PPA_PATH)/swi-prolog-ubuntu-stable-bionic.list:
	@sudo add-apt-repository -y ppa:swi-prolog/stable

.PHONY:	debug-all
debug-all: ## Display all make variables defined
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(warning $V = $($V) ) \
	)

committer:  /usr/bin/git
	@git config --local user.email "conrado.rgz@gmail.com" && git config --local user.name "Conrado Rodriguez"