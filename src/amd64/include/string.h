#ifndef __STRING_H__
#define __STRING_H__
#include <stddef.h>

#define memset(dest, value, count) memset_see1(dest, value, count)
void* memset_byte(void* dest, int value, size_t count);
void* memset_long(void* dest, int value, size_t count);
void* memset_see1(void* dest, int value, size_t count);
void* memset_see2(void* dest, int value, size_t count);
void* memset_avx2(void* dest, int value, size_t count);
uint64_t hash1(const char *str);
uint64_t hash2(const char *str);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t count);
char *strcat(char *dest, const char *src);
char *strncat(char *dest, const char *src, size_t count);
int strcmp(const char *str1, const char *str2);
int strncmp(const char *str1, const char *str2, size_t count);
size_t strlen(char *str);


#endif
