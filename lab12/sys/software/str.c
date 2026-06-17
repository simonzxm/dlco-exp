#include "str.h"

int str_eq(const char *a, const char *b) {
    while (*a && *b) {
        if (*a != *b)
            return 0;
        a++;
        b++;
    }
    return *a == *b;
}

// string to integer
int str_to_i(const char *s) {
    int v = 0;
    while (*s == ' ')
        s++;
    while (*s >= '0' && *s <= '9') {
        v = v * 10 + (*s - '0');
        s++;
    }
    return v;
}

int str_len(const char *s) {
    int n = 0;
    while (s[n])
        n++;
    return n;
}

void str_copy(char *dst, const char *src, int cap) {
    int i = 0;
    while (i < cap - 1 && src[i]) {
        dst[i] = src[i];
        i++;
    }
    dst[i] = '\0';
}
