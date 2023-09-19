#ifndef _WASP_H
#define _WASP_H

void *__WASP_alloc(void *, unsigned int);
void __WASP_dealloc(void *);

int __WASP_symb_int(char *);
long long __WASP_symb_long(char *);
float __WASP_symb_float(char *);
double __WASP_symb_double(char *);

void __WASP_assume(int);
void __WASP_assert(int);
int __WASP_is_symbolic(void *, unsigned int);

void assume(int);

/* int __WASP_print_stack(int); */
/* void __WASP_print_pc(); */

int and_(int, int);
int or_(int, int);
/* int ite(int, int, int); */

#endif
