#include <owi.h>
#include <stdlib.h>

int main() {
  int n = owi_i32();
  owi_assume(n > 2);
  owi_assume(n < 16);

  int *chunk = (int *)malloc(sizeof(int) * 8);
  for (int i = 0; i < n; i++)
    chunk[i] = 0;

  return 0;
}
