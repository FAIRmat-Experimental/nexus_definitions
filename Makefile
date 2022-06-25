# File: Makefile

# purpose:
#	build resources in NeXus definitions tree

SUBDIRS = manual impatient-guide
PYTHON = python3
DIR_NAME = "$(shell basename $(realpath .))"
BUILD_DIR = "build"

.PHONY: $(SUBDIRS)  all clean html pdf nxdl2rst prepare test local

all ::
ifneq ($(DIR_NAME), $(BUILD_DIR))
	# root directory
	make test
	make prepare
	make -C $(BUILD_DIR) all
else
	# root/build directory
	make clean
	make impatient-guide
	make nxdl2rst
	make html
	make pdf

	cp impatient-guide/_build/latex/NXImpatient.pdf manual/build/html/_static/NXImpatient.pdf
	cp manual/build/latex/nexus.pdf manual/build/html/_static/NeXusManual.pdf

	@echo "HTML built: `ls -lAFgh manual/build/html/index.html`"
	@echo "PDF built: `ls -lAFgh manual/build/latex/nexus.pdf`"
endif

clean ::
	for dir in $(SUBDIRS); do \
	    $(MAKE) -C $$dir clean; \
	done

impatient-guide ::
ifeq ($(DIR_NAME), $(BUILD_DIR))
	$(MAKE) html -C $@
	$(MAKE) latexpdf -C $@
endif

html ::
ifeq ($(DIR_NAME), $(BUILD_DIR))
	$(MAKE) html -C manual
endif

nxdl2rst ::
ifeq ($(DIR_NAME), $(BUILD_DIR))
	$(MAKE) -C manual/source PYTHON=$(PYTHON)
endif

pdf ::
ifeq ($(DIR_NAME), $(BUILD_DIR))
	# expect pass to fail (thus exit 0) since nexus.ind not found first time
	# extra option needed to satisfy "levels nested too deeply" error
	($(MAKE) latexpdf LATEXOPTS="--interaction=nonstopmode -f" -C manual || exit 0)

	# make that missing file
	makeindex manual/build/latex/nexus.idx

	# second pass will also fail but we can ignore it without problem
	($(MAKE) latexpdf LATEXOPTS="--interaction=nonstopmode -f" -C manual || exit 0)

	# third time should be no errors
	($(MAKE) latexpdf LATEXOPTS="--interaction=nonstopmode -f" -C manual || exit 0)
endif

prepare ::
ifneq ($(DIR_NAME), $(BUILD_DIR))
	echo "In root directory, can $@"
	$(RM) -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	$(PYTHON) utils/build_preparation.py . $(BUILD_DIR)
endif

test ::
	$(PYTHON) utils/test_suite.py

# for developer's use on local build host
local ::
	make test
	make prepare
	$(MAKE) nxdl2rst -C $(BUILD_DIR)
	$(MAKE) html -C $(BUILD_DIR)

# NeXus - Neutron and X-ray Common Data Format
#
# Copyright (C) 2008-2022 NeXus International Advisory Committee (NIAC)
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# For further information, see http://www.nexusformat.org
