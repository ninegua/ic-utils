CANISTERS=hello
SRC=$(CANISTERS:%=src/%.mo)
OBJ=$(CANISTERS:%=dist/%.wasm)
OBJ_OPT=$(CANISTERS:%=dist/%-opt.wasm)
IDL=$(CANISTERS:%=dist/%.did)

build: $(OBJ) $(IDL)

clean:
	rm -f $(OBJ) $(OBJ_OPT) $(IDL)

really-clean: clean
	rm -rf run

.PHONY: build clean really-clean
