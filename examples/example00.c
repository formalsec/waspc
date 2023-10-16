#include <owi.h>

int main() {
  int a = owi_i32();
  owi_assume(a > 0);

  int b = owi_i32();
  owi_assume(b == a + 1);

  owi_assert(b > 0);
  return 0;
}
