#ifndef __STDARG_H__
#define __STDARG_H__

#include <stddef.h>

#if defined(va_list)
#elif defined(__builtin_va_list) || defined(__GNUC__)
    typedef __builtin_va_list va_list;
#else
    typedef ptr_t va_list;
#endif

#if defined(va_rounded_size)
#elif defined(__va_rounded_size)
    #define va_rounded_size(type) __va_rounded_size(type)
#else
    #define va_rounded_size(type) (((sizeof(type) + sizeof(int) - 1) / sizeof(int)) * sizeof(int))
#endif

#if defined(va_start)
#elif defined(__builtin_va_start) || defined(__GNUC__)
    #define va_start(ap, last) __builtin_va_start(ap, last)
#else
    #define va_start(ap, last) (ap = ((char *) &(last) + va_rounded_size (last)))
#endif

#if defined(va_arg)
#elif defined(__builtin_va_arg) || defined(__GNUC__)
    #define va_arg(ap, type) __builtin_va_arg(ap, type)
#else
    #define va_arg(ap, type) (*((type*)((ap += va_rounded_size (type)) - va_rounded_size (type))))
#endif

#if defined(va_end)
#elif defined(__builtin_va_end) || defined(__GNUC__)
    #define va_end(ap) __builtin_va_end(ap)
#else
    #define va_end(ap) (ap = (va_list) NULL)
#endif

#if defined(va_copy)
#elif defined(__builtin_va_copy) || defined(__GNUC__)
    #define va_copy(d, s) __builtin_va_copy(d, s)
#else
    #define va_copy(d, s) (d = s)
#endif

#if defined(va_arg_count)
#elif defined(__builtin_va_arg_count) || defined(__GNUC__)
    #define va_arg_count(ap) __builtin_va_arg_count(ap)
#else
    #define va_arg_count(ap) ((int) (((char *) &(ap) + sizeof(ap)) - (char *) &(ap)))
#endif

#endif
