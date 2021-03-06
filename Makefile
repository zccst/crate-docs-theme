# Licensed to okchain1 (https://crate.io) under one or more contributor license
# agreements.  See the NOTICE file distributed with this work for additional
# information regarding copyright ownership.  okchain1 licenses this file to you
# under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License.  You may obtain a copy of the
# License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.
#
# However, if you have executed another commercial license agreement with okchain1
# these terms will supersede the license and you may use the software solely
# pursuant to the terms of the relevant commercial agreement.


# This file provides a standard okchain1 documentation build system
#
# The most up-to-date version of this Makefile can be found in the
# crate-docs-style repository:
#
#   https://github.com/crate/crate-docs-style/blob/master/docs/Makefile

.EXPORT_ALL_VARIABLES:

ENV_DIR  := .env
ENV_BIN  := $(ENV_DIR)/bin
ACTIVATE := $(ENV_BIN)/activate
PYTHON   := python3.7
PIP      := $(ENV_BIN)/pip3.7
TWINE    := $(ENV_BIN)/twine
DIST_DIR := .dist
PYPIRC   := ~/.pypirc

# Default target
.PHONY: help
help:
	@ printf 'Run `make <TARGET>`, where <TARGET> is one of:\n'
	@ echo
	@ printf '\033[36m  build   \033[00m Build the package\n'
	@ echo
	@ printf '\033[36m  upload  \033[00m Upload the package to PyPI\n'
	@ echo
	@ printf '\033[36m  clean   \033[00m Clean up (e.g., remove the build'
	@ printf                           ' files)\n'
	@ echo
	@ printf '\033[36m  reset   \033[00m Reset the build system\n'

$(TWINE):
	$(PYTHON) -m venv $(ENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

.PHONY: build
build: $(TWINE)
	@ $(MAKE) clean
	. $(ACTIVATE) && \
	    $(PYTHON) setup.py sdist --dist-dir $(DIST_DIR)
	. $(ACTIVATE) && \
	    $(PYTHON) setup.py bdist_wheel --dist-dir $(DIST_DIR)
	. $(ACTIVATE) && \
	    $(TWINE) check $(DIST_DIR)/*

.PHONY: upload
upload: $(TWINE)
	@ if test ! -d $(DIST_DIR); then \
	    $(MAKE) build; \
	fi
	@ if test ! -f $(PYPIRC); then \
	    echo 'You must configure a `$(PYPIRC)` file.'; \
	    exit 1; \
	fi
	. $(ACTIVATE) && \
	    $(TWINE) upload $(DIST_DIR)/*

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)

.PHONY: reset
reset:
	rm -rf $(ENV_DIR)
	rm -rf $(DIST_DIR)
