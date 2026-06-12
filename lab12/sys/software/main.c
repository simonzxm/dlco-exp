#include "io.h"
#include "str.h"
#include "sys.h"

int main();

// setup the entry point
void entry() {
    asm("lui sp, 0x00120"); // set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

static void cmd_hello(const char *args) {
    (void)args;
    println("Hello World!");
}

static void cmd_time(const char *args) {
    (void)args;
    // TODO
    println("time: not implemented");
}

static void cmd_fibn(const char *args) {
    int n = stoi(args);
    unsigned int a = 0, b = 1;
    for (int i = 0; i < n; i++) {
        unsigned int t = a + b;
        a = b;
        b = t;
    }
    println("F(", n, ") = ", a);
}

#define COMMAND_LIST(X)                                                        \
    X("hello", cmd_hello)                                                      \
    X("time", cmd_time)                                                        \
    X("fibn", cmd_fibn)

static char *split_args(char *line) {
    char *p = line;
    while (*p && *p != ' ')
        p++;
    if (*p == '\0')
        return p;
    *p++ = '\0';
    while (*p == ' ')
        p++;
    return p;
}

static void run_command(char *line) {
    char *cmd = line;
    char *args = split_args(line);
#define X(name, fn)                                                            \
    if (streq(cmd, name)) {                                                    \
        fn(args);                                                              \
        return;                                                                \
    }
    COMMAND_LIST(X)
#undef X
    if (cmd[0])
        println("Unknown Command.");
}

int main() {
    vga_init();
    char line[80];
    while (1) {
        print_str("> ");
        read_line(line, sizeof line);
        run_command(line);
    }
    return 0;
}
