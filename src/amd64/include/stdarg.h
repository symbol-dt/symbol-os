#ifndef __STDARG_H__
#define __STDARG_H__

#include <stddef.h>

#ifndef __builtin_va_list
    #define __builtin_va_list ptr_t
#endif
#define __va_rounded_size(type) (((sizeof(type) + sizeof(int) - 1) / sizeof(int)) * sizeof(int))
#ifndef __builtin_va_start
    #define __builtin_va_start(ap, last) (ap = ((char *) &(last) + __va_rounded_size (last)))
#endif
#ifndef __builtin_va_arg
    #define __builtin_va_arg(ap, type) (*((type*)((ap += __va_rounded_size (type)) - __va_rounded_size (type))))
#endif
#ifndef __builtin_va_end
    #define __builtin_va_end(ap) (ap = (va_list) NULL)
#endif
#ifndef __builtin_va_copy
    #define __builtin_va_copy(d, s) (d = s)
#endif

typedef __builtin_va_list va_list;
#define va_start(ap, last) __builtin_va_start(ap, last)
#define va_end(ap) __builtin_va_end(ap)
#define va_arg(ap, type) __builtin_va_arg(ap, type)
#define va_copy(dest, src) __builtin_va_copy(dest, src)
int va_arg_count(va_list ap);

#endif
