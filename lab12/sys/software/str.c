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

// Returns 1 if needle occurs in hay (empty needle always matches).
int str_contains(const char *hay, const char *needle) {
    if (!needle[0])
        return 1;
    for (; *hay; hay++) {
        int i = 0;
        while (hay[i] && needle[i] && hay[i] == needle[i])
            i++;
        if (!needle[i])
            return 1;
    }
    return 0;
}
