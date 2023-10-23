#include <owi.h>

int main() {
  int v = owi_i32();
  owi_assume(v == 42);
  owi_assert(v == 42);
  return 0;
}
