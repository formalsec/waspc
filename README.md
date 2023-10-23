# owic

OWI's C frontend

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Before you begin using this software, make sure to check that the following
essential dependencies are installed on your system: `clang`, `llvm`, `lld`,
and `wabt`.

The recommended way to acquire these dependencies is through your Linux
distribution's package manager.

### Installation

First, install [opam](https://opam.ocaml.org/doc/Install.html). Then, bootstrap
the OCaml compiler:

```sh
opam switch create 5.1.0 5.1.0
```

Then, install the library dependencies:

```sh
git clone https://github.com/wasp-platform/waspc
cd waspc
opam install . --deps-only
```

Build and install:

```sh
dune build @install
dune install
```

## Usage

Given a file `examples/example00.c`:

```c
#include <owi.h>

int main() {
  int v = owi_i32();
  owi_assume(v == 42);
  owi_assert(v == 42);
  return 0;
}
```

To compile this program and run this program simply:

```sh
$ owic examples/example00.c
$ owi sym owi-out/a.out.wat
CHECK:
(bool.not (i32.eq symbol_1 (i32 42)))
(i32.eq symbol_1 (i32 42))/CHECK OK
PATH CONDITION:
(i32.eq symbol_1 (i32 42))
All OK

Solver time 0.001161s
      calls 1
  mean time 1.161000ms
```

**TODO:** In the *near* future `owic` will automatically invoke `owi sym`
