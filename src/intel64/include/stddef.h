#ifndef __STDDEF_H__
#define __STDDEF_H__

typedef unsigned long size_t;
typedef char *ptr_t;
#define NULL ((void*)0)
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
#define container_of(ptr, type, member) ({                      \
        const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
        (type *)( (char *)__mptr - offsetof(type,member) );})

#endif
