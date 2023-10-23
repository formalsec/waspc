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

## External Functions

To compile a C program that includes external functions, one can add the
necessary `__attribute__` definitions for these external functions, as shown
in the example `examples/extern_func.c`:

```c
__attribute__((import_module("db"), import_name("get"))) int get();
__attribute__((import_module("db"), import_name("set"))) void set(int);

void incr() {
  int count = get();
  set(count + 1);
}

int main() {
  incr();
  return 0;
}
```

The code above compiles to the following WebAssembly (Wasm) module:

```wast
(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (param i32)))
  (type (;2;) (func))
  (import "db" "get" (func $get (type 0)))
  (import "db" "set" (func $set (type 1)))
  (func $__original_main (type 0) (result i32)
    call $get
    i32.const 1
    i32.add
    call $set
    i32.const 0)
  (func $_start (type 2)
    call $__original_main
    drop)
  (table (;0;) 1 1 funcref)
  (memory (;0;) 129)
  (global $__stack_pointer (mut i32) (i32.const 8389632))
  (export "memory" (memory 0))
  (export "_start" (func $_start)))
```

See [host functions](https://github.com/OCamlPro/owi/tree/main/example#using-and-defining-external-functions-host-functions))
for host function implementation in `owi`.

### Available Host Functions in OWI

`owi` provides a set of host functions to create and manipulate symbolic values.
The signature of these host functions is defined in the `owi.h` header file, which
should be included in your C program to use them. Here is a summary of some of
the available host functions:

```c
#ifndef _OWI_H
#define _OWI_H
...
int owi_i32(void);
long long owi_i64(void);
float owi_f32(void);
double owi_f64(void);

void owi_assume(int c);
void owi_assert(int c);
...
#endif
```

- `owi_i32(void)`: Create a symbolic 32-bit integer.
- `owi_i64(void)`: Create a symbolic 64-bit integer.
- `owi_f32(void)`: Create a symbolic 32-bit float.
- `owi_f64(void)`: Create a symbolic 64-bit double.
- `owi_assume(int c)`: Add a condition to the solver. This function simply
    introduces a condition into the symbolic execution path.
- `owi_assert(int c)`: Assert a condition under the current path condition in
    the solver. If this condition is not met, it indicates a potential issue in
    the code.
