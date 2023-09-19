#include "wasp.h"

void assume(int expr) { return __WASP_assume(expr); }
int __WASP_is_symbolic(void *var, unsigned int sz) { return 1; }
/* int __WASP_print_stack(int a) { return 0; } */
/* void __WASP_print_pc() {} */

/* special boolean ops */
int and_(int a, int b) {
  __asm__ __volatile__("local.get 0;"
                       "i32.const 0;"
                       "i32.ne;"
                       "local.get 1;"
                       "i32.const 0;"
                       "i32.ne;"
                       "i32.and;"
                       "return;");
}

int or_(int a, int b) {
  __asm__ __volatile__("local.get 0;"
                       "i32.const 0;"
                       "i32.ne;"
                       "local.get 1;"
                       "i32.const 0;"
                       "i32.ne;"
                       "i32.or;"
                       "return;");
}

/* int ite(int cond, int a, int b) { return cond ? a : b; } */
