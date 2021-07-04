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
  - [x] Create, top-up, install, and call canisters (without using cycles wallets).
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
It includes a few other IC tools and binaries: [quill], [keysmith], `moc` from [Motoko], `icx` from [agent-rs].
Please feel free to include the unpacked `bin` sub-directory in your `PATH` environment, but this is not required.

One of the command in the unpacked `bin` sub-directory is `ic-init-project`.
As an example, you can setup a `Makefile` in a new or existing directory like this:

```
ic-init-project .
```

It will first check the existence of a few system tools (`make` from [GNU Make], `protoc` from [protobuf], [jq] and [xxd]) in `PATH`.
Most likely you can have all of them installed via the preferred package installation of your distro.

To use the `Makefile` once it is setup, you also need to set the `PEM_FILE` environment variable.
It has to point to a file holding the private key of the principal you want to use for development.
If you have used `dfx`, it usually is `~/.config/dfx/identity/default/identity.pem`.
Or create a new one using [keysmith].
This is required for creating and installing canisters on the IC, and you will need some ICPs on this account to pay for cycles too.

You can try it out by playing with a sample "hello" project:
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

What is nice of using `Makefile` is that a command like `make call/...` will perform all prerequisite steps before calling the canister.
This may include compiling Wasm, creating, installing or updating canisters, and so on.
It is a big time saver when it comes to source code editing and testing loops.

Start build now by editing the `Makefile`!

Built products like Wasm and Candid files are put in `dist` sub-directory, and network installation status are put in the `run` sub-directory.
But permanent canister IDs on IC are recorded in `canister_ids.json` file.
You are advised to make backups of this file or track it in your git repository.

### Development

If you want to contribute to this project, the fastest way to develop is to install [nix] and run `nix-shell`, which will launch you in a shell with all required dependencies ready to use.

[Motoko]: https://github.com/dfinity/motoko
[Canisters]: https://sdk.dfinity.org/docs/developers-guide/concepts/canisters-code.html
[Internet Computer]: https://sdk.dfinity.org/docs/developers-guide/concepts/what-is-ic
[dfx]: https://sdk.dfinity.org/docs/developers-guide/install-upgrade-remove.html
[Makefile]: https://www.gnu.org/software/make/manual/make.html
[nix]: https://nixos.org/nix
[GNU Make]: https://www.gnu.org/software/make
[protobuf]: https://developers.google.com/protocol-buffers/docs/downloads
[jq]: https://stedolan.github.io/jq/download
[xxd]: https://github.com/ConorOG/xxd
[keysmith]: https://github.com/dfinity/keysmith
[quill]: https://github.com/dfinity/quill
[agent-rs]: https://github.com/dfinity/agent-rs
[vessel]: https://github.com/dfinity/vessel
