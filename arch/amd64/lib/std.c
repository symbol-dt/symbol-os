#include <stdarg.h>

int va_arg_count(va_list ap){
    int count = 0;
    va_list ap_copy;
    va_copy(ap_copy, ap);
    while(va_arg(ap_copy, int) != 0)
        count++;
    va_end(ap_copy);
    return count;
}
