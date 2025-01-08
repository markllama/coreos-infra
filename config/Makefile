#!/bin/make -f
BUTANE_FILES_DIR=$(HOME)/.ssh
DOMAIN=lamourine.org

all: intel-1.ign intel-2.ign intel-3.ign pi4-1.ign

intel-1.ign: fcos-base.bu.j2
	jinja2 -D hostname=intel-1.$(DOMAIN) fcos-base.bu.j2 | \
	butane --files-dir=$(BUTANE_FILES_DIR) > intel-1.ign

intel-2.ign: fcos-base.bu.j2
	jinja2 -D hostname=intel-2.$(DOMAIN) fcos-base.bu.j2 | \
	butane --files-dir=$(BUTANE_FILES_DIR) > intel-2.ign

intel-3.ign: fcos-base.bu.j2
	jinja2 -D hostname=intel-3.$(DOMAIN) fcos-base.bu.j2 | \
	butane --files-dir=$(BUTANE_FILES_DIR) > intel-3.ign

pi4-1.ign: fcos-base.bu.j2
	jinja2 -D hostname=pi4-1.$(DOMAIN) fcos-base.bu.j2 | \
	butane --files-dir=$(BUTANE_FILES_DIR) > pi4-1.ign

