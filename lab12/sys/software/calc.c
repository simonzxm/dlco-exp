#include "calc.h"
#include "io.h"
#include "mathcop.h"

typedef struct {
    int is_float;
    float f;
    int i;
} cval;

static const char *P;
static int err;

static cval mkf(float f) {
    cval v;
    v.is_float = 1;
    v.f = f;
    v.i = 0;
    return v;
}

static cval mki(int i) {
    cval v;
    v.is_float = 0;
    v.i = i;
    v.f = 0.0f;
    return v;
}

static float to_f(cval v) { return v.is_float ? v.f : mc_itof(v.i); }

static int fzero(float f) {
    union {
        float f;
        unsigned int u;
    } t;
    t.f = f;
    return (t.u & 0x7fffffffu) == 0u;
}

static void skip(void) {
    while (*P == ' ')
        P++;
}

static cval apply(char op, cval a, cval b) {
    if (a.is_float || b.is_float) {
        float x = to_f(a), y = to_f(b), r = 0.0f;
        if (op == '+')
            r = mc_fadd(x, y);
        else if (op == '-')
            r = mc_fsub(x, y);
        else if (op == '*')
            r = mc_fmul(x, y);
        else if (fzero(y))
            err = 1;
        else
            r = mc_fdiv(x, y);
        return mkf(r);
    }
    int x = a.i, y = b.i, r = 0;
    if (op == '+')
        r = x + y;
    else if (op == '-')
        r = x - y;
    else if (op == '*')
        r = x * y;
    else if (y == 0)
        err = 1;
    else
        r = x / y;
    return mki(r);
}

static cval parse_number(void) {
    int ipart = 0;
    while (*P >= '0' && *P <= '9')
        ipart = ipart * 10 + (*P++ - '0');
    if (*P == '.') {
        P++;
        int fpart = 0, fcount = 0, scale = 1;
        while (*P >= '0' && *P <= '9') {
            fpart = fpart * 10 + (*P++ - '0');
            scale = scale * 10;
            fcount++;
        }
        float f = mc_itof(ipart);
        if (fcount > 0)
            f = mc_fadd(f, mc_fdiv(mc_itof(fpart), mc_itof(scale)));
        return mkf(f);
    }
    return mki(ipart);
}

static cval parse_expr(void);

static cval parse_factor(void) {
    skip();
    if (*P == '-') {
        P++;
        cval v = parse_factor();
        return v.is_float ? mkf(mc_fsub(0.0f, v.f)) : mki(-v.i);
    }
    if (*P == '+') {
        P++;
        return parse_factor();
    }
    if (*P == '(') {
        P++;
        cval v = parse_expr();
        skip();
        if (*P == ')')
            P++;
        else
            err = 1;
        return v;
    }
    if (*P >= '0' && *P <= '9')
        return parse_number();
    err = 1;
    return mki(0);
}

static cval parse_term(void) {
    cval a = parse_factor();
    skip();
    while (!err && (*P == '*' || *P == '/')) {
        char op = *P++;
        a = apply(op, a, parse_factor());
        skip();
    }
    return a;
}

static cval parse_expr(void) {
    cval a = parse_term();
    skip();
    while (!err && (*P == '+' || *P == '-')) {
        char op = *P++;
        a = apply(op, a, parse_term());
        skip();
    }
    return a;
}

void cmd_calc(const char *args) {
    P = args;
    err = 0;
    skip();
    if (*P == '\0') {
        println("usage: calc <expr>");
        return;
    }
    cval v = parse_expr();
    skip();
    if (err || *P != '\0') {
        println("calc: error");
        return;
    }
    if (v.is_float)
        println(v.f);
    else
        println(v.i);
}
