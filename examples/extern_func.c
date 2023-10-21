#include <owi.h>

__attribute__((import_module("env"), import_name("get"))) int get();
__attribute__((import_module("env"), import_name("set"))) void set(int);

int main() {
  int count = get();
  if (count > 0) {
    owi_assert(0);
  }
  set(10);
  return 0;
}
