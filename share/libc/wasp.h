#ifndef _WASP_H
#define _WASP_H

/* memory operations */
__attribute__((import_module("summaries"), import_name("alloc"))) void *
__WASP_alloc(void *, unsigned int);
__attribute__((import_module("summaries"), import_name("dealloc"))) void
__WASP_dealloc(void *);

/* symbolic values */
__attribute__((import_module("symbolic"), import_name("i32_symbol"))) int
__WASP_symb_int(char *);
__attribute__((import_module("symbolic"), import_name("i64_symbol"))) long long
__WASP_symb_long(char *);
__attribute__((import_module("symbolic"), import_name("f32_symbol"))) float
__WASP_symb_float(char *);
__attribute__((import_module("symbolic"), import_name("f64_symbol"))) double
__WASP_symb_double(char *);

/* symbolic variable manipulation */

__attribute__((import_module("symbolic"), import_name("assume"))) void
__WASP_assume(int);
__attribute__((import_module("symbolic"), import_name("assert"))) void
__WASP_assert(int);
int __WASP_is_symbolic(void *, unsigned int);

void assume(int);

/* debug operations*/
/* int __WASP_print_stack(int); */
/* void __WASP_print_pc(); */

/* special boolean ops */
__attribute__((import_module("symbolic"), import_name("and_"))) int and_(int,
                                                                         int);
__attribute__((import_module("symbolic"), import_name("or_"))) int or_(int,
                                                                       int);
/* int ite(int, int, int); */

#endif
