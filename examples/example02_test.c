#include <owi.h>

void test(int a, int b) {
  if (a && b) {
    owi_assert(a);
  } else {
    if (!a) {
    }
    if (!b) {
    }
  }
  owi_assert(a || (!a && b) || !b);
}
