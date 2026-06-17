#ifndef IO_H
#define IO_H

void read_line(char *buf, int size);

void print_str(const char *s);
void print_int(int n);
void print_uint(unsigned int n);
void print_char(char c);

void out_redirect(char *buf, int cap);
void out_restore(void);

#define print_selector(x)                                                      \
    _Generic((x),                                                              \
        char *: print_str,                                                     \
        const char *: print_str,                                               \
        int: print_int,                                                        \
        unsigned int: print_uint,                                              \
        char: print_char,                                                      \
        default: print_int)

#define print1(x) print_selector(x)(x)
#define print2(a, b)                                                           \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
    } while (0)
#define print3(a, b, c)                                                        \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
    } while (0)
#define print4(a, b, c, d)                                                     \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
    } while (0)
#define print5(a, b, c, d, e)                                                  \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
    } while (0)
#define print6(a, b, c, d, e, f)                                               \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
        print1(f);                                                             \
    } while (0)
#define print7(a, b, c, d, e, f, g)                                            \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
        print1(f);                                                             \
        print1(g);                                                             \
    } while (0)
#define print8(a, b, c, d, e, f, g, h)                                         \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
        print1(f);                                                             \
        print1(g);                                                             \
        print1(h);                                                             \
    } while (0)
#define print9(a, b, c, d, e, f, g, h, i)                                      \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
        print1(f);                                                             \
        print1(g);                                                             \
        print1(h);                                                             \
        print1(i);                                                             \
    } while (0)
#define print10(a, b, c, d, e, f, g, h, i, j)                                  \
    do {                                                                       \
        print1(a);                                                             \
        print1(b);                                                             \
        print1(c);                                                             \
        print1(d);                                                             \
        print1(e);                                                             \
        print1(f);                                                             \
        print1(g);                                                             \
        print1(h);                                                             \
        print1(i);                                                             \
        print1(j);                                                             \
    } while (0)

#define println1(x)                                                            \
    do {                                                                       \
        print1(x);                                                             \
        print_char('\n');                                                      \
    } while (0)
#define println2(a, b)                                                         \
    do {                                                                       \
        print2(a, b);                                                          \
        print_char('\n');                                                      \
    } while (0)
#define println3(a, b, c)                                                      \
    do {                                                                       \
        print3(a, b, c);                                                       \
        print_char('\n');                                                      \
    } while (0)
#define println4(a, b, c, d)                                                   \
    do {                                                                       \
        print4(a, b, c, d);                                                    \
        print_char('\n');                                                      \
    } while (0)
#define println5(a, b, c, d, e)                                                \
    do {                                                                       \
        print5(a, b, c, d, e);                                                 \
        print_char('\n');                                                      \
    } while (0)
#define println6(a, b, c, d, e, f)                                             \
    do {                                                                       \
        print6(a, b, c, d, e, f);                                              \
        print_char('\n');                                                      \
    } while (0)
#define println7(a, b, c, d, e, f, g)                                          \
    do {                                                                       \
        print7(a, b, c, d, e, f, g);                                           \
        print_char('\n');                                                      \
    } while (0)
#define println8(a, b, c, d, e, f, g, h)                                       \
    do {                                                                       \
        print8(a, b, c, d, e, f, g, h);                                        \
        print_char('\n');                                                      \
    } while (0)
#define println9(a, b, c, d, e, f, g, h, i)                                    \
    do {                                                                       \
        print9(a, b, c, d, e, f, g, h, i);                                     \
        print_char('\n');                                                      \
    } while (0)
#define println10(a, b, c, d, e, f, g, h, i, j)                                \
    do {                                                                       \
        print10(a, b, c, d, e, f, g, h, i, j);                                 \
        print_char('\n');                                                      \
    } while (0)

#define print_get_macro(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, NAME, ...) NAME
#define print(...)                                                             \
    print_get_macro(__VA_ARGS__, print10, print9, print8, print7, print6,      \
                    print5, print4, print3, print2, print1)(__VA_ARGS__)
#define println(...)                                                           \
    print_get_macro(__VA_ARGS__, println10, println9, println8, println7,      \
                    println6, println5, println4, println3, println2,          \
                    println1)(__VA_ARGS__)

#endif
