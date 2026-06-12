#include "sys.h"

char *vga_start = (char *)VGA_START;
volatile char *vga_cursor = (volatile char *)VGA_CURSOR;
volatile int *vga_lineo = (volatile int *)VGA_LINE_O;

int vga_line = 0;
int vga_ch = 0;
int start_line = 0;

static void clear_line(int line) {
    for (int j = 0; j < VGA_MAXCOL; j++)
        vga_start[(line << 7) + j] = 0;
}

static void new_line() {
    vga_ch = 0;
    vga_line++;
    if (vga_line >= VGA_MAXLINE)
        vga_line = 0;
    if (vga_line == start_line) {
        start_line++;
        if (start_line >= VGA_MAXLINE)
            start_line = 0;
        *vga_lineo = start_line;
        clear_line(vga_line);
    }
}

// Tell the VGA which cell holds the (non-blinking, reverse-video) cursor.
static void move_cursor(void) { vga_cursor[(vga_line << 7) + vga_ch] = 0; }

void vga_init() {
    vga_line = 0;
    vga_ch = 0;
    start_line = 0;
    *vga_lineo = 0;
    for (int i = 0; i < VGA_MAXLINE; i++)
        clear_line(i);
    move_cursor();
}

void putch(char ch) {
    if (ch == '\r' || ch == '\n') {
        new_line();
        move_cursor();
        return;
    }
    if (ch == 8 || ch == 127) {
        if (vga_ch > 0) {
            vga_ch--;
        } else if (vga_line != start_line) {
            vga_line = (vga_line == 0) ? VGA_MAXLINE - 1 : vga_line - 1;
            vga_ch = VGA_MAXCOL - 1;
        }
        vga_start[(vga_line << 7) + vga_ch] = 0;
        move_cursor();
        return;
    }
    vga_start[(vga_line << 7) + vga_ch] = ch;
    vga_ch++;
    if (vga_ch >= VGA_MAXCOL)
        new_line();
    move_cursor();
}

char getch(void) {
    static int last_count = 0;
    volatile unsigned int *key_reg = (volatile unsigned int *)KEY_START;
    while (1) {
        unsigned int w = *key_reg;
        int count = (int)((w >> 8) & 0xff);
        if (count != last_count) {
            last_count = count;
            return (char)(w & 0xff);
        }
    }
}

// Move the write cursor one cell to the left without erasing
void cursor_left(void) {
    if (vga_ch > 0) {
        vga_ch--;
    } else if (vga_line != start_line) {
        vga_line = (vga_line == 0) ? VGA_MAXLINE - 1 : vga_line - 1;
        vga_ch = VGA_MAXCOL - 1;
    }
    move_cursor();
}
