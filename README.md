# Internet Computer Utilities for Canister Development

We provide a collection of utilities for developing [Canisters] for the [Internet Computer] (IC) blockchain, all without using [dfx].

**WARNING: Very experimental at the moment, try at your own risk!**

### Objectives

Except the testing and deployment part, canister development is largely the same as ordinary software development.
To better cope with the growing complexity, we should:

- Allow projects to use familiar build tools, most notably, the [Makefile].
- Prefer the composition of a variety of tools instead of one monolithic binary.

### Features

- [x] Tools for interacting with system canisters on the IC including the ledger.
- [x] Makefile based command line workflow including
  - [x] Create, topup, install, and call canisters (without using cycles wallets).
  - [ ] Uninstall canisters after collecting remaining cycles.
- [x] Interacting with IC.
- [ ] Running a local replica for testing.
- [x] Project setup for [Motoko] backend.
- [ ] Project setup for JS frontend.
- [ ] Project setup for C and Rust backends.
- [x] Linux support.
- [ ] Darwin (OS X) support.
- [ ] WSL (Windows) support.

### Get started

Download a binary release package and unpack it somewhere on the system.
There are several commands in the `bin` sub-directory, and one of them is `ic-init-project`.
The following command sets up a `Makefile` in the current directory:

```
ic-init-project .
```

It requires a few system tools like `make` from [GNU Make], `protoc` from [protobuf], [jq] and [xxd], and will give error if not found.
Most likely you can get all of them from the standard package installation of your distro.

It also requires the `PEM_FILE` environment variable to point to a PEM file that has your private key of the principal you use for development.
You can use what `dfx` uses, e.g. `~/.config/dfx/identity/default/identity.pem`, or create a new one using [keysmith].
This is required for creating and installing canisters on the IC, and you will need some ICPs on this account to pay for cycles too.

Here is an example of starting the example "hello" project:
```
make init-hello
```

To learn about what else can be done, there is `make help`:

```
$ make help

The following are examples of using this Makefile, assuming you have a
project called 'hello' written in 'src/hello.mo'.

Install to IC, and initialize it with cycles converted from 0.02 ICPs:

    make install/hello ICP=0.02 MODE=install

Call its method 'greet' with an argument:

    make call/hello METHOD=greet ARG='("world")'

Commonly used make targets are in the form of '<action>/<canister>'.
The <action> is one of: 'install', 'topup', 'status', 'call' and 'query'.

Commonly used variable settings:

  METHOD    method name to call on the canister
  ARG       argument list encoded in Candid text format.
  MODE      one of 'install', 'reinstall' and 'upgrade' (default)
  IC        network URI, e.g. 'http://localhost:8000' for a local setup.

All canisters installed in IC will have their canister ids created in
file 'canister_ids.json'. Make sure you don't lose this file, otherwise
you may lose access to your canisters if you don't have their ids.
```

### Development

If you want to contribute to this project, the fastest way to develop is to install [nix] and run `nix-shell`, which will launch you in a shell with all required dependendies ready to use.

[Motoko]: https://github.com/dfinity/motoko
[Canisters]: https://sdk.dfinity.org/docs/developers-guide/concepts/canisters-code.html
[Internet Computer]: https://sdk.dfinity.org/docs/developers-guide/concepts/what-is-ic
[dfx]: https://sdk.dfinity.org/docs/developers-guide/install-upgrade-remove.html
[Makefile]: https://www.gnu.org/software/make/manual/make.html
[nix]: https://nixos.org/nix
[GNU Make]: https://www.gnu.org/software/make
[protoc]: https://developers.google.com/protocol-buffers/docs/downloads
[jq]: https://stedolan.github.io/jq/download
[xxd]: https://github.com/ConorOG/xxd
