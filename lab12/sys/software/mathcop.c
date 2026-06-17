#include "mathcop.h"
#include "sys.h"

typedef union {
    float f;
    unsigned int u;
} fu;

static unsigned int mc_op(unsigned int a, unsigned int b, unsigned int op) {
    volatile unsigned int *m = (volatile unsigned int *)MATH_START;
    m[0] = a;
    m[1] = b;
    m[2] = op;
    while (m[4] & 1u) {
    }
    return m[3];
}

unsigned int mc_imul(unsigned int a, unsigned int b) { return mc_op(a, b, 0u); }
unsigned int mc_udiv(unsigned int a, unsigned int b) { return mc_op(a, b, 1u); }
unsigned int mc_urem(unsigned int a, unsigned int b) { return mc_op(a, b, 2u); }

float mc_fadd(float a, float b) {
    fu x, y, r;
    x.f = a;
    y.f = b;
    r.u = mc_op(x.u, y.u, 3u);
    return r.f;
}

float mc_fsub(float a, float b) {
    fu x, y, r;
    x.f = a;
    y.f = b;
    r.u = mc_op(x.u, y.u, 4u);
    return r.f;
}

float mc_fmul(float a, float b) {
    fu x, y, r;
    x.f = a;
    y.f = b;
    r.u = mc_op(x.u, y.u, 5u);
    return r.f;
}

float mc_fdiv(float a, float b) {
    fu x, y, r;
    x.f = a;
    y.f = b;
    r.u = mc_op(x.u, y.u, 6u);
    return r.f;
}

float mc_itof(int i) {
    fu r;
    r.u = mc_op((unsigned int)i, 0u, 7u);
    return r.f;
}

int mc_ftoi(float f) {
    fu x;
    x.f = f;
    return (int)mc_op(x.u, 0u, 8u);
}
