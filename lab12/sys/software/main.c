#include "fs.h"
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

volatile unsigned int *time_reg = (volatile unsigned int *)TIME_START;

static void print_2digit(unsigned int v) {
    print_char((char)('0' + (v / 10u) % 10u));
    print_char((char)('0' + v % 10u));
}

// Returns -1 on bad input.
static int parse_hms(const char *s) {
    unsigned int field[3] = {0, 0, 0};
    for (int i = 0; i < 3; i++) {
        if (*s < '0' || *s > '9')
            return -1;
        unsigned int v = 0;
        while (*s >= '0' && *s <= '9')
            v = v * 10u + (unsigned int)(*s++ - '0');
        field[i] = v;
        if (i < 2) {
            if (*s != ':')
                return -1;
            s++;
        }
    }
    while (*s == ' ')
        s++;
    if (*s != '\0')
        return -1;
    if (field[0] > 23 || field[1] > 59 || field[2] > 59)
        return -1;
    return (int)(field[0] * 3600u + field[1] * 60u + field[2]);
}

static void cmd_time(const char *args) {
    if (args[0] == '\0') {
        unsigned int t = *time_reg;
        print_2digit((t / 3600u) % 24u);
        print_char(':');
        print_2digit((t / 60u) % 60u);
        print_char(':');
        print_2digit(t % 60u);
        print_char('\n');
        return;
    }
    if (str_eq(args, "set") || (args[0] == 's' && args[1] == 'e' &&
                                args[2] == 't' && args[3] == ' ')) {
        const char *p = args + 3;
        while (*p == ' ')
            p++;
        int secs = parse_hms(p);
        if (secs < 0) {
            println("usage: time set HH:MM:SS");
            return;
        }
        *time_reg = (unsigned int)secs;
        return;
    }
    println("usage: time | time set HH:MM:SS");
}

static void cmd_fibn(const char *args) {
    int n = str_to_i(args);
    unsigned int a = 0, b = 1;
    for (int i = 0; i < n; i++) {
        unsigned int t = a + b;
        a = b;
        b = t;
    }
    println(a);
}

#define COMMAND_LIST(X)                                                        \
    X("hello", cmd_hello)                                                      \
    X("time", cmd_time)                                                        \
    X("fibn", cmd_fibn)                                                        \
    X("pwd", cmd_pwd)                                                          \
    X("cd", cmd_cd)                                                            \
    X("ls", cmd_ls)                                                            \
    X("cat", cmd_cat)                                                          \
    X("mkdir", cmd_mkdir)                                                      \
    X("rm", cmd_rm)                                                            \
    X("rmdir", cmd_rmdir)

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
    if (str_eq(cmd, name)) {                                                   \
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
    fs_init();
    char line[80];
    while (1) {
        print_str("> ");
        read_line(line, sizeof line);
        run_command(line);
    }
    return 0;
}
