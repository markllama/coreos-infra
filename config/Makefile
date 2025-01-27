#!/bin/make -f
SSH_FILES_DIR=$(HOME)/.ssh
DOMAIN=lamourine.org

HOSTS=intel-1 intel-2 intel-3 pi4-1 pi4-2 pi4-3 pi4-4 pi5-1 pi5-2 pi5-3 pi5-4

CONFIGS=$(shell echo ${HOSTS} | tr ' ' "\n" | xargs -I{} echo {}.ign)

all: $(CONFIGS)

$(CONFIGS):%.ign:fcos-base.bu.j2
	@echo target is $@, source is $<
	FCOS_HOSTNAME=$(shell basename $@ .ign) ; \
	jinja2 -D hostname=$${FCOS_HOSTNAME}.$(DOMAIN) $< | \
	butane --pretty --files-dir $(SSH_FILES_DIR) --output $@
