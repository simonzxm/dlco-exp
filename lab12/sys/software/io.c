#include "io.h"
#include "sys.h"

#define KEY_HOME 0x01
#define KEY_LEFT 0x02
#define KEY_END 0x05
#define KEY_RIGHT 0x06
#define KEY_BS 0x08
#define KEY_DEL 0x7F

// Redraw buf[pos..len) starting at the current cursor
static void redraw(const char *buf, int pos, int len) {
    for (int i = pos; i < len; i++)
        putch(buf[i]);
    putch(' ');
    for (int i = len + 1; i > pos; i--)
        cursor_left();
}

void read_line(char *buf, int size) {
    int len = 0;
    int pos = 0;
    while (1) {
        char ch = getch();
        if (ch == '\r' || ch == '\n') {
            while (pos < len)
                putch(buf[pos++]);
            putch('\n');
            buf[len] = '\0';
            return;
        } else if (ch == KEY_BS) {
            if (pos > 0) {
                for (int i = pos; i < len; i++)
                    buf[i - 1] = buf[i];
                pos--;
                len--;
                cursor_left();
                redraw(buf, pos, len);
            }
        } else if (ch == KEY_DEL) {
            if (pos < len) {
                for (int i = pos + 1; i < len; i++)
                    buf[i - 1] = buf[i];
                len--;
                redraw(buf, pos, len);
            }
        } else if (ch == KEY_LEFT) {
            if (pos > 0) {
                cursor_left();
                pos--;
            }
        } else if (ch == KEY_RIGHT) {
            if (pos < len)
                putch(buf[pos++]);

        } else if (ch == KEY_HOME) {
            while (pos > 0) {
                cursor_left();
                pos--;
            }
        } else if (ch == KEY_END) {
            while (pos < len)
                putch(buf[pos++]);
        } else if (ch < 0x20) {
            // ignore other/unmapped control characters
        } else if (len < size - 1) {
            for (int i = len; i > pos; i--)
                buf[i] = buf[i - 1];
            buf[pos] = ch;
            len++;
            for (int i = pos; i < len; i++)
                putch(buf[i]);
            for (int i = len; i > pos + 1; i--)
                cursor_left();
            pos++;
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
