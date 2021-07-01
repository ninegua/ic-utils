SRC=src/hello.mo
WASM=dist/hello.wasm
IDL=dist/hello.idl

IC?=https://ic0.app
IC_MANAGEMENT_ID=aaaaa-aa
PEM?=${PEM_FILE}
INSTALL_MODE?=reinstall
ifdef NAME
  CANISTER_ID=$(shell cat canister_ids.json|jq -r ".$(NAME)|.ic")
  ifndef DID_OPT
    DID_OPT=--candid dist/$(NAME).did
  endif
endif
ERR_FILE?=$(shell mktemp)

build: $(WASM) $(IDL)

dist:
	mkdir -p dist

dist/%.wasm: src/%.mo dist
	moc $$(vessel sources) -o $@ $<

dist/%-opt.wasm: dist/%.wasm dist
	ic-cdk-optimizer -o $@ $<

dist/%.idl: dist src/%.mo
	moc $$(vessel sources) --idl -o $@ $<

clean:
	rm -f $(WASM)

create_canister:
	icx --pem $(PEM) $(IC_MANAGEMENT_ID) create_canister 

install:
	mkdir -p install

install/%: install dist/%-opt.wasm
	@$(MAKE) --no-print-directory install_code NAME=$(subst install/,,$@) && touch $@

.PRECIOUS: install/%

status/%:
	@$(MAKE) --no-print-directory canister_status NAME=$(subst status/,,$@)

call/%: install/%
	@$(MAKE) --no-print-directory call NAME=$(subst call/,,$@) METHOD='$(METHOD)' ARG='$(ARG)'

query/%: install/%
	@$(MAKE) --no-print-directory query NAME=$(subst query/,,$@) METHOD='$(METHOD)' ARG='$(ARG)'

check-PEM:
	@: $(if $(PEM),,$(error environment PEM_FILE is undefined))

check-%:
	@: $(if $(value $*),,$(error $* is undefined))

.ONESHELL:
canister_status:| check-IC check-PEM check-NAME check-CANISTER_ID
	icx --pem $(PEM) $(IC) update $(DID_OPT) $(IC_MANAGEMENT_ID) canister_status "(record { canister_id = principal \"$(CANISTER_ID)\"; })" 2> $(ERR_FILE)
	test "$$?" = 0 || $(MAKE) --no-print-directory print-error ERR_FILE=$(ERR_FILE) || exit 1

.ONESHELL:
install_code:| check-IC check-NAME check-PEM check-CANISTER_ID
	@set e
	wasm_bytes=$$(python -c 'print repr(open("dist/$(NAME)-opt.wasm","rb").read())'|sed -e 's/\\\\/\\x5c/g' -e 's/\\n/\\0a/g' -e 's/\\x/\\/g' -e 's/"/\\22/g' -e "s/^'//" -e "s/'$$//")
	echo "(record { mode = variant { $(INSTALL_MODE) }; canister_id = principal \"$(CANISTER_ID)\"; wasm_module = blob \"$$wasm_bytes\"; arg = blob \"\"; })" | \
		icx --pem $(PEM) $(IC) update --candid did/ic.did $(IC_MANAGEMENT_ID) install_code - 2> $(ERR_FILE)
	test "$$?" = 0 || $(MAKE) --no-print-directory print-error ERR_FILE=$(ERR_FILE) || exit 1
	echo "Installed canister $(NAME) ($(CANISTER_ID))."

.ONESHELL:
call:| check-IC check-NAME check-PEM check-METHOD check-ARG check-CANISTER_ID
	@set e
	icx --pem $(PEM) $(IC) update $(DID_OPT) $(CANISTER_ID) $(METHOD) '$(ARG)' 2> $(ERR_FILE)
	test "$$?" = 0 || $(MAKE) --no-print-directory ERR_FILE=$(ERR_FILE) || exit 1

.ONESHELL:
query:| check-IC check-NAME check-PEM check-METHOD check-ARG
	@set e
	icx --pem $(PEM) $(IC) query $(DID_OPT) $(CANISTER_ID) $(METHOD) '$(ARG)' 2> $(ERR_FILE)
	test "$$?" = 0 || $(MAKE) --no-print-directory ERR_FILE="$(ERR_FILE)" || exit 1

print-error: check-ERR_FILE
	@cat $(ERR_FILE) | awk '(/^  Content:/ && ORS=" ") { "echo " $$2 " | xxd -r -p" | getline result; print "  " $$1 " " result; next } {print}' && rm $(ERR_FILE) && exit 1

.PHONY: build clean install_code call query print-error check-%
