#include <stdlib.h>

int main() {
    int* ptr = (int*)malloc(sizeof(int));
    /* ptr leak */
    return 0;
}
