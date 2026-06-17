#include "calc.h"
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

static void cmd_echo(const char *args) {
    print(args);
    print_char('\n');
}

// Input piped from the previous pipeline stage (0 when there is none).
static const char *g_stdin = 0;

static void cmd_grep(const char *args) {
    const char *in = g_stdin;
    if (!in)
        return;
    char line[160];
    while (*in) {
        int n = 0;
        while (*in && *in != '\n') {
            if (n < (int)sizeof line - 1)
                line[n++] = *in;
            in++;
        }
        line[n] = '\0';
        if (*in == '\n')
            in++;
        if (str_contains(line, args))
            println(line);
    }
}

static void cmd_clear(const char *args) {
    (void)args;
    vga_clear();
}

#define COMMAND_LIST(X)                                                        \
    X("hello", cmd_hello)                                                      \
    X("clear", cmd_clear)                                                      \
    X("time", cmd_time)                                                        \
    X("fibn", cmd_fibn)                                                        \
    X("calc", cmd_calc)                                                        \
    X("echo", cmd_echo)                                                        \
    X("grep", cmd_grep)                                                        \
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

// Run a single command (one pipeline stage). Output goes to the active sink.
static void dispatch(char *stage) {
    char *cmd = stage;
    char *args = split_args(stage);
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

// Strip leading and trailing spaces in place.
static char *trim_stage(char *s) {
    while (*s == ' ')
        s++;
    int len = str_len(s);
    while (len > 0 && s[len - 1] == ' ')
        s[--len] = '\0';
    return s;
}

// Parse <, > and >> redirections
static char *parse_redir(char *s, const char **infile, const char **outfile,
                         int *append) {
    *infile = 0;
    *outfile = 0;
    *append = 0;
    char *w = s;
    char *r = s;
    int wrote = 0;
    while (*r) {
        while (*r == ' ')
            r++;
        if (!*r)
            break;
        char c = *r;
        if (c == '<' || c == '>') {
            r++;
            int ap = 0;
            if (c == '>' && *r == '>') {
                ap = 1;
                r++;
            }
            while (*r == ' ')
                r++;
            char *name = r;
            while (*r && *r != ' ')
                r++;
            if (*r)
                *r++ = '\0';
            if (c == '<')
                *infile = name;
            else {
                *outfile = name;
                *append = ap;
            }
        } else {
            char *tok = r;
            while (*r && *r != ' ')
                r++;
            if (*r)
                *r++ = '\0';
            if (wrote)
                *w++ = ' ';
            while (*tok)
                *w++ = *tok++;
            wrote = 1;
        }
    }
    *w = '\0';
    return s;
}

#define MAX_STAGES 8
#define PIPE_BUF 1024

static void run_command(char *line) {
    char *stages[MAX_STAGES];
    int n = 0;
    stages[n++] = line;
    for (char *p = line; *p; p++) {
        if (*p == '|') {
            *p = '\0';
            if (n < MAX_STAGES)
                stages[n++] = p + 1;
        }
    }

    static char bufA[PIPE_BUF], bufB[PIPE_BUF], filebuf[PIPE_BUF];
    const char *prev = 0;
    for (int i = 0; i < n; i++) {
        const char *infile, *outfile;
        int append;
        char *stage =
            parse_redir(trim_stage(stages[i]), &infile, &outfile, &append);

        if (infile) {
            g_stdin = fs_read(infile);
            if (!g_stdin) {
                println("no such file: ", infile);
                continue;
            }
        } else {
            g_stdin = prev;
        }

        char *cur = (i & 1) ? bufB : bufA;
        if (outfile)
            out_redirect(filebuf, PIPE_BUF);
        else if (i < n - 1)
            out_redirect(cur, PIPE_BUF);
        else
            out_restore();

        dispatch(stage);

        if (outfile) {
            out_restore();
            if (fs_write(outfile, filebuf, append) < 0)
                println("cannot write: ", outfile);
            prev = 0;
        } else if (i < n - 1) {
            prev = cur;
        }
    }
    out_restore();
    g_stdin = 0;
}

int main() {
    vga_init();
    fs_init();
    char line[80];
    while (1) {
        print_str("$ ");
        read_line(line, sizeof line);
        run_command(line);
    }
    return 0;
}
