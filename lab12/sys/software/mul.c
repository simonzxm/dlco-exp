#include "mathcop.h"

unsigned int __mulsi3(unsigned int a, unsigned int b) { return mc_imul(a, b); }

unsigned int __udivsi3(unsigned int a, unsigned int b) { return mc_udiv(a, b); }

unsigned int __umodsi3(unsigned int a, unsigned int b) { return mc_urem(a, b); }

int __divsi3(int a, int b) {
    int neg = (a < 0) ^ (b < 0);
    unsigned int ua = (a < 0) ? (unsigned int)(-a) : (unsigned int)a;
    unsigned int ub = (b < 0) ? (unsigned int)(-b) : (unsigned int)b;
    unsigned int q = mc_udiv(ua, ub);
    return neg ? -(int)q : (int)q;
}

int __modsi3(int a, int b) {
    unsigned int ua = (a < 0) ? (unsigned int)(-a) : (unsigned int)a;
    unsigned int ub = (b < 0) ? (unsigned int)(-b) : (unsigned int)b;
    unsigned int r = mc_urem(ua, ub);
    return (a < 0) ? -(int)r : (int)r;
}
