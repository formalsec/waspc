#include <stdlib.h>

int main() {
  int *chunk = (int *)malloc(sizeof(int) * 8);
  free(chunk);
  free(chunk);

  return 0;
}
