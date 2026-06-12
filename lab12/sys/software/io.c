#include "io.h"
#include "sys.h"

void read_line(char *buf, int size) {
    int len = 0;
    while (1) {
        char ch = getch();
        if (ch == '\r' || ch == '\n') {
            putch('\n');
            buf[len] = '\0';
            return;
        }
        if (ch == 8 || ch == 127) {
            if (len > 0) {
                len--;
                putch(ch);
            }
            continue;
        }
        if (len < size - 1) {
            buf[len++] = ch;
            putch(ch);
        }
    }
}

void print_char(char c) { putch(c); }

void print_str(const char *s) {
    while (*s)
        putch(*s++);
}

void print_uint(unsigned int n) {
    char tmp[12];
    int i = 0;
    if (n == 0) {
        putch('0');
        return;
    }
    while (n) {
        tmp[i++] = (char)('0' + (n % 10u));
        n /= 10u;
    }
    while (i > 0)
        putch(tmp[--i]);
}

void print_int(int n) {
    unsigned int u;
    if (n < 0) {
        putch('-');
        u = (unsigned int)(-(n + 1)) + 1u; // avoid INT_MIN overflow
    } else {
        u = (unsigned int)n;
    }
    print_uint(u);
}
