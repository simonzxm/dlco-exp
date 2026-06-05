#include "sys.h"

char *vga_start = (char *)VGA_START;
volatile int *vga_lineo = (volatile int *)VGA_LINE_O;

int vga_line = 0;    // physical vram row of the cursor (0..VGA_MAXLINE-1)
int vga_ch = 0;      // cursor column (0..VGA_MAXCOL-1)
int start_line = 0;  // physical row currently shown at the top of the screen

static void clear_line(int line) {
    for (int j = 0; j < VGA_MAXCOL; j++)
        vga_start[(line << 7) + j] = 0;
}

void vga_init() {
    vga_line = 0;
    vga_ch = 0;
    start_line = 0;
    *vga_lineo = 0;
    for (int i = 0; i < VGA_MAXLINE; i++)
        clear_line(i);
}

// Move the cursor to the start of the next line, scrolling the screen up by one
// (via the hardware start-row register) when it would wrap onto the top line.
static void newline() {
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

void putch(char ch) {
    if (ch == '\r' || ch == '\n') {  // enter / newline
        newline();
        return;
    }
    if (ch == 8 || ch == 127) {  // backspace / delete
        if (vga_ch > 0) {
            vga_ch--;
        } else if (vga_line != start_line) {  // back up to end of previous line
            vga_line = (vga_line == 0) ? VGA_MAXLINE - 1 : vga_line - 1;
            vga_ch = VGA_MAXCOL - 1;
        }
        vga_start[(vga_line << 7) + vga_ch] = 0;
        return;
    }
    vga_start[(vga_line << 7) + vga_ch] = ch;
    vga_ch++;
    if (vga_ch >= VGA_MAXCOL)  // auto-wrap at end of line
        newline();
}

void putstr(char *str) {
    for (char *p = str; *p != 0; p++)
        putch(*p);
}

// Block until a key is pressed, then return its ASCII code. The keyboard
// peripheral packs {key_count, ascii_key}; key_count bumps on every keypress,
// so a changed count means a fresh key is available.
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
