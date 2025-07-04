#ifndef __STRING_H__
#define __STRING_H__

#include <stddef.h>
#include <stdint.h>

void memsetw(void *s, uint16_t data, size_t n);
void memcopy(void *dest, const void *src, size_t n);

#endif