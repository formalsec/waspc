#include <owi.h>

int main() {
  int a = owi_i32();
  int b;

  if (a > 0) {
    b = a + 1;
    owi_assert(b > 0);
  }

  return 0;

}
