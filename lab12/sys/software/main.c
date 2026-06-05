#include "sys.h"

int main();

// setup the entry point
void entry() {
    asm("lui sp, 0x00120"); // set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

int main() {
    vga_init();
    while (1) {
        putch(getch());
    }
    return 0;
}
