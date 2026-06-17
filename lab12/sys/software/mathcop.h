#ifndef MATHCOP_H
#define MATHCOP_H

unsigned int mc_imul(unsigned int a, unsigned int b);
unsigned int mc_udiv(unsigned int a, unsigned int b);
unsigned int mc_urem(unsigned int a, unsigned int b);

float mc_fadd(float a, float b);
float mc_fsub(float a, float b);
float mc_fmul(float a, float b);
float mc_fdiv(float a, float b);
float mc_itof(int i);
int mc_ftoi(float f);

#endif
