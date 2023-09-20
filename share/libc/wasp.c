#include "wasp.h"

__attribute__((import_module("summaries"), import_name("alloc"))) void *
owi_alloc(void *, unsigned int);
__attribute__((import_module("summaries"), import_name("dealloc"))) void
owi_dealloc(void *);

void *__WASP_alloc(void *ptr, unsigned int size) {
  return owi_alloc(ptr, size);
}

void __WASP_dealloc(void *ptr) { return owi_dealloc(ptr); }

__attribute__((import_module("symbolic"), import_name("i32_symbol"))) int
i32_symbol();
__attribute__((import_module("symbolic"), import_name("i64_symbol"))) long long
i64_symbol();
__attribute__((import_module("symbolic"), import_name("f32_symbol"))) float
f32_symbol();
__attribute__((import_module("symbolic"), import_name("f64_symbol"))) double
f64_symbol();

int __WASP_symb_int(char *name) {
  return i32_symbol();
}
long long __WASP_symb_long(char *name) { return i64_symbol(); }
float __WASP_symb_float(char *name) { return f32_symbol(); }
double __WASP_symb_double(char *name) { return f64_symbol(); }

__attribute__((import_module("symbolic"), import_name("assume"))) void
owi_assume(int);
__attribute__((import_module("symbolic"), import_name("assert"))) void
owi_assert(int);

void __WASP_assume(int expr) { owi_assume(expr); }
void __WASP_assert(int expr) { owi_assert(expr); }

void assume(int expr) { return __WASP_assume(expr); }

__attribute__((import_module("summaries"), import_name("is_symbolic"))) int
owi_is_symbolic(void *var, unsigned int);
int __WASP_is_symbolic(void *var, unsigned int sz) { return owi_is_symbolic(var, sz); }

/* int __WASP_print_stack(int a) { return 0; } */
/* void __WASP_print_pc() {} */

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
