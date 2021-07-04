# PEM file that has the private key
PEM?=${PEM_FILE}
ifdef PEM
  PEM_OPT=--pem $(PEM)
endif

# System constants
IC_MANAGEMENT_ID=aaaaa-aa
IC_LEDGER_ID=ryjl3-tyaaa-aaaaa-aaaba-cai
IC_CYCLES_MINTING_ID=rkp4c-7iaaa-aaaaa-aaaca-cai
MEMO_CREATE_CANISTER=0x41455243
MEMO_TOP_UP_CANISTER=0x50555054
TRANSACTION_FEE=10_000

# Default installation mode
INSTALL_MODE?=reinstall

# Network related settings
ifndef IC
  IC=https://ic0.app
  NETWORK=ic
  RUN_DIR=run/ic
NETWORK_IS_IC:
else
  NETWORK:=$(shell echo "$(IC)"|sed -e 's/https:\|http://' -e 's/:[0-9]*//' -e 's|/||g')
  RUN_DIR=run/$(NETWORK)
  ICX_OPT=--fetch-root-key
NETWORK_IS_NOT_IC:
endif

# Canister related settings
ifdef NAME
  RUN_DIR_CANISTER_ID=$(RUN_DIR)/canister_id-$(NAME)
  CANISTER_ID=$(shell cat $(RUN_DIR_CANISTER_ID))
  ifndef DID_OPT
    DID_OPT=--candid dist/$(NAME).did
  endif
endif

OUT_FILE:=$(shell mktemp -u)

ifndef ERR_FILE
  ERR_FILE:=$(shell mktemp -u)
endif

settings: check-PEM check-IC
	@echo "IC=$(IC)"
	@echo "NETWORK=$(NETWORK)"
	@echo "RUN_DIR=$(RUN_DIR)"
	@echo "PEM=$(PEM)"

dist:
	@mkdir -p $@

$(RUN_DIR):
	@mkdir -p $@

dist/%.wasm: src/%.mo | dist
	moc $$(vessel sources) -o $@ $<

dist/%-opt.wasm: dist/%.wasm
	ic-cdk-optimizer -o $@ $<

dist/%.did: src/%.mo | dist
	moc $$(vessel sources) --idl -o $@ $<

.PRECIOUS: $(RUN_DIR)/canister_id-% $(RUN_DIR)/installed-% dist/%-opt.wasm

$(RUN_DIR)/installed-%: $(RUN_DIR)/canister_id-% dist/%-opt.wasm | $(RUN_DIR)
	@$(MAKE) --no-print-directory install_code NAME=$(subst $(RUN_DIR)/installed-,,$@) && touch $@

install/%: $(RUN_DIR)/installed-%
	@:

topup/%:
	@$(MAKE) --no-print-directory canister_topup NAME=$(subst topup/,,$@)

status/%:
	@$(MAKE) --no-print-directory canister_status NAME=$(subst status/,,$@)

call/%: $(RUN_DIR)/installed-%
	@$(MAKE) --no-print-directory call NAME=$(subst call/,,$@) METHOD='$(METHOD)' ARG='$(ARG)'

query/%: $(RUN_DIR)/installed-%
	@$(MAKE) --no-print-directory query NAME=$(subst query/,,$@) METHOD='$(METHOD)' ARG='$(ARG)'

check-PEM:
	@: $(if $(PEM),,$(error environment PEM_FILE is undefined))

check-%:
	@: $(if $(value $*),,$(error $* is undefined))

canister_ids.json:
	echo {} > $@

.ONESHELL:
run/ic/canister_id-%: canister_ids.json| $(RUN_DIR) check-IC check-PEM NETWORK_IS_IC
	@canister_id=$$(cat canister_ids.json|jq -r ".$*|.$(NETWORK)")
	test "$$canister_id" != null && echo "$$canister_id" > $@
	test "$$canister_id" = null -a -z "$$ICP" && \
		echo "Need ICP to create a canister on IC" && exit 1
	test "$$canister_id" = null && \
		NETWORK="$(NETWORK)" ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" \
			"$(UTIL_DIR)/bin/ledger" create_canister $(ICP) > $(OUT_FILE) && \
		test -s $(OUT_FILE) && \
		cp $(OUT_FILE) $@ && canister_id=$$(cat $@)
	cat canister_ids.json |jq ".$* += {\"$(NETWORK)\": \"$$canister_id\"}" > $(OUT_FILE) && \
		mv $(OUT_FILE) canister_ids.json

.ONESHELL:
$(RUN_DIR)/canister_id-%:| $(RUN_DIR) check-IC check-PEM NETWORK_IS_NOT_IC
	@echo 'On $(IC) create an empty canister "$*" with 10 TC'
	NETWORK="$(NETWORK)" ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" \
		"$(UTIL_DIR)/bin/ic" provisional_create_canister > $(OUT_FILE)
	test -s $(OUT_FILE) && cat $(OUT_FILE) | cut -d\" -f2 > $@ && rm -f $(RUN_DIR)/installed-$*

create_canister: $(RUN_DIR_CANISTER_ID) | check-IC check-PEM check-NAME

canister_topup:| check-IC check-NAME check-CANISTER_ID check-ICP
	@echo 'On $(IC) top-up canister "$(NAME)" $(CANISTER_ID)'
	ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" \
		"$(UTIL_DIR)/bin/ledger" topup_canister $(CANISTER_ID) $(ICP)

canister_status:| check-IC check-NAME check-CANISTER_ID
	@echo 'On $(IC) getting canister_status of "$(NAME)" $(CANISTER_ID)'
	ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" \
		"$(UTIL_DIR)/bin/ic" canister_status $(CANISTER_ID) $(METHOD)

install_code: dist/$(NAME)-opt.wasm | check-IC check-NAME check-PEM check-CANISTER_ID
	@echo 'On $(IC) $(INSTALL_MODE) "$(NAME)" $(CANISTER_ID)'
	ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" INSTALL_MODE="$(INSTALL_MODE)" \
		"$(UTIL_DIR)/bin/ic" install_code $(CANISTER_ID) "$<" && \
		echo 'Installed canister "$(NAME)" ($(CANISTER_ID)).'

call:| check-IC check-NAME check-METHOD check-ARG check-CANISTER_ID
	@echo 'On $(IC) calling "$(NAME)" $(CANISTER_ID): $(METHOD) $(ARG)'
	ICX_OPT="$(ICX_OPT)" PEM_OPT="$(PEM_OPT)" IC="$(IC)" DID_OPT="$(DID_OPT)" \
		"$(UTIL_DIR)/bin/canister" update $(CANISTER_ID) $(METHOD) '$(ARG)'

query:| check-IC check-NAME check-PEM check-METHOD check-ARG
	@echo 'On $(IC) querying "$(NAME)" $(CANISTER_ID): $(METHOD) $(ARG)'
	PEM_OPT="$(PEM_OPT)" IC="$(IC)" DID_OPT="$(DID_OPT)" \
		"$(UTIL_DIR)/bin/canister" query $(CANISTER_ID) $(METHOD) '$(ARG)'

.PHONY: install_code call query check-% install/% status/% call/% query/% topup/%

init-vessel:
	vessel init

init-hello: init-vessel
	mkdir -p src
	cp $(UTIL_DIR)/share/example/hello.mo src/

help:
	@echo "The following are examples of using this Makefile, assuming you have a"
	@echo "project called 'hello' written in 'src/hello.mo'."
	@echo
	@echo "Install to IC, and initialize it with cycles converted from 0.02 ICPs:"
	@echo
	@echo "    make install/hello ICP=0.02"
	@echo
	@echo "Call its method 'greet' with an argument:"
	@echo 
	@echo "    make call/hello METHOD=greet ARG='(\"world\")'"
	@echo
	@echo "Commonly used make targets are in the form of '<action>/<canister>'."
	@echo "The <action> is one of: 'install', 'topup', 'status', 'call' and 'query'."
	@echo
	@echo "The 'call' and 'query' actions must take additional parameters:"
	@echo "- METHOD is the function name"
	@echo "- ARG is the argument list encoded in Candid text format."
	@echo
	@echo "Set variable IC to use with an existing replica running on a local port."
	@echo "For example: 'IC=http://localhost:8000'."
	@echo
	@echo "All canisters installed in IC will have their canister ids created in"
	@echo "file 'canister_ids.json'. Make sure you don't lose this file, otherwise"
	@echo "you may lose access to your canisters if you don't have their ids."
	@echo ".PHONY: init-vessel init-hello help"
