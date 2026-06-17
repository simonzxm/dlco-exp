#ifndef SYS_H
#define SYS_H

#define VGA_START 0x00200000
#define VGA_CURSOR 0x00208000
#define VGA_LINE_O 0x00210000
#define VGA_MAXLINE 30
#define LINE_MASK 0x003f
#define VGA_MAXCOL 80
#define KEY_START 0x00300000
#define TIME_START 0x00400000
#define MATH_START 0x00500000

extern int vga_line;
extern int vga_ch;

void vga_init(void);
void vga_clear(void);

void putch(char ch);
char getch(void);
void cursor_left(void);

#endif
