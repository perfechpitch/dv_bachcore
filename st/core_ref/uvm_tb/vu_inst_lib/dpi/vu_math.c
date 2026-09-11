#include "vu_math.h"

#include <float.h>
#include <math.h>
#include <mpfr.h>
#include <stdlib.h>
#include <string.h>

static float vu_bits_to_fp32(uint32_t bits)
{
    float value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static uint32_t vu_fp32_to_bits(float value)
{
    uint32_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

static int vu_fp32_is_nan_bits(uint32_t bits)
{
    return ((bits & UINT32_C(0x7f800000)) == UINT32_C(0x7f800000)) &&
           ((bits & UINT32_C(0x007fffff)) != 0);
}

uint32_t vu_bf16_to_fp32(uint32_t value)
{
    return (value & UINT32_C(0xffff)) << 16;
}

uint32_t vu_fp32_to_bf16(uint32_t bits, uint32_t round_mode)
{
    uint32_t upper;
    uint32_t lower;
    uint32_t sign;
    uint32_t increment;

    upper = bits >> 16;
    lower = bits & UINT32_C(0xffff);
    sign = bits >> 31;
    increment = 0;

    if(vu_fp32_is_nan_bits(bits)) {
        upper |= UINT32_C(0x0040);
        return upper & UINT32_C(0xffff);
    }

    switch(round_mode & 7U) {
    case 0: /* RNE */
        increment = (lower > UINT32_C(0x8000)) ||
                    (lower == UINT32_C(0x8000) && (upper & 1U));
        break;
    case 1: /* RTZ */
        increment = 0;
        break;
    case 2: /* RDN */
        increment = sign && lower;
        break;
    case 3: /* RUP */
        increment = !sign && lower;
        break;
    case 4: /* RMM */
        increment = lower >= UINT32_C(0x8000);
        break;
    case 5: /* RNO */
        increment = (lower > UINT32_C(0x8000)) ||
                    (lower == UINT32_C(0x8000) && !(upper & 1U));
        break;
    case 6: /* RS: deterministic RNE fallback in the reference model. */
    default:
        increment = (lower > UINT32_C(0x8000)) ||
                    (lower == UINT32_C(0x8000) && (upper & 1U));
        break;
    }

    return (upper + increment) & UINT32_C(0xffff);
}

static float vu_round_magnitude(float value, uint32_t round_mode, int negative)
{
    float floor_value;
    float frac;
    uint32_t integer;

    floor_value = floorf(value);
    frac = value - floor_value;
    integer = (uint32_t)floor_value;

    switch(round_mode & 7U) {
    case 1: /* RTZ */
        return floor_value;
    case 2: /* RDN */
        return negative && frac != 0.0f ? floor_value + 1.0f : floor_value;
    case 3: /* RUP */
        return !negative && frac != 0.0f ? floor_value + 1.0f : floor_value;
    case 4: /* RMM */
        return frac >= 0.5f ? floor_value + 1.0f : floor_value;
    case 5: /* RNO */
        if(frac > 0.5f || (frac == 0.5f && !(integer & 1U)))
            return floor_value + 1.0f;
        return floor_value;
    case 0: /* RNE */
    case 6: /* RS: deterministic RNE fallback. */
    default:
        if(frac > 0.5f || (frac == 0.5f && (integer & 1U)))
            return floor_value + 1.0f;
        return floor_value;
    }
}

uint32_t vu_fp8e4m3_to_fp32(uint32_t raw)
{
    uint32_t sign;
    uint32_t exponent;
    uint32_t mantissa;
    float value;

    raw &= UINT32_C(0xff);
    sign = raw >> 7;
    exponent = (raw >> 3) & 0xfU;
    mantissa = raw & 7U;

    if(exponent == 0U) {
        value = ldexpf((float)mantissa / 8.0f, -6);
    } else if(exponent == 0xfU && mantissa == 7U) {
        return UINT32_C(0x7fc00000);
    } else {
        value = ldexpf(1.0f + (float)mantissa / 8.0f,
                       (int)exponent - 7);
    }

    if(sign)
        value = -value;
    return vu_fp32_to_bits(value);
}

uint32_t vu_fp32_to_fp8e4m3(uint32_t bits, uint32_t round_mode)
{
    float value;
    float magnitude;
    float rounded;
    int exponent;
    uint32_t sign;
    uint32_t exp_field;
    uint32_t mantissa;

    sign = bits >> 31;
    if(vu_fp32_is_nan_bits(bits))
        return (sign << 7) | UINT32_C(0x7f);

    value = vu_bits_to_fp32(bits);
    magnitude = fabsf(value);

    if(isinf(magnitude) || magnitude > 448.0f)
        return (sign << 7) | UINT32_C(0x7e);
    if(magnitude == 0.0f)
        return sign << 7;

    if(magnitude < ldexpf(1.0f, -6)) {
        rounded = vu_round_magnitude(magnitude / ldexpf(1.0f, -9),
                                     round_mode, (int)sign);
        mantissa = (uint32_t)rounded;
        if(mantissa == 0U)
            return sign << 7;
        if(mantissa >= 8U)
            return (sign << 7) | UINT32_C(0x08);
        return (sign << 7) | mantissa;
    }

    exponent = (int)floorf(log2f(magnitude));
    if(exponent < -6)
        exponent = -6;
    rounded = vu_round_magnitude(
        (magnitude / ldexpf(1.0f, exponent) - 1.0f) * 8.0f,
        round_mode,
        (int)sign
    );
    mantissa = (uint32_t)rounded;
    if(mantissa >= 8U) {
        mantissa = 0U;
        exponent++;
    }
    if(exponent > 8)
        return (sign << 7) | UINT32_C(0x7e);

    exp_field = (uint32_t)(exponent + 7);
    if(exp_field == 0xfU && mantissa == 7U)
        mantissa = 6U;
    return (sign << 7) | (exp_field << 3) | mantissa;
}

static uint32_t vu_value_to_fp32(uint32_t value, uint32_t data_type)
{
    return data_type ? vu_bf16_to_fp32(value) : value;
}

static uint32_t vu_overflow_value(uint32_t data_type,
                                  uint32_t round_mode, int negative)
{
    uint32_t infinity = data_type ? 0x7f80U : 0x7f800000U;
    uint32_t sign = negative ? (data_type ? 0x8000U : 0x80000000U) : 0U;
    int finite = round_mode == 1U || (round_mode == 2U && !negative) ||
                 (round_mode == 3U && negative);

    return sign | (finite ? infinity - 1U : infinity);
}

static uint32_t vu_mpfr_to_value(mpfr_srcptr value, uint32_t data_type,
                                 uint32_t round_mode, int side)
{
    mpfr_t scaled;
    mpfr_exp_t exponent;
    long shift;
    unsigned int fraction_bits = data_type ? 7U : 23U;
    unsigned long significand;
    unsigned long hidden = 1UL << fraction_bits;
    uint32_t sign;
    int negative;
    int magnitude_side;
    int fraction_nonzero;
    int halfway;
    int increment;

    if(mpfr_nan_p(value))
        return data_type ? 0x7fc0U : 0x7fc00000U;
    negative = mpfr_signbit(value) != 0;
    if(mpfr_zero_p(value) && side != 0)
        negative = side < 0;
    sign = negative ? (data_type ? 0x8000U : 0x80000000U) : 0U;
    if(mpfr_inf_p(value))
        return sign | (data_type ? 0x7f80U : 0x7f800000U);
    if(mpfr_zero_p(value)) {
        increment = side != 0 && ((round_mode == 2U && negative) ||
                                  (round_mode == 3U && !negative));
        return sign | (uint32_t)increment;
    }

    mpfr_init2(scaled, mpfr_get_prec(value));
    mpfr_abs(scaled, value, MPFR_RNDN);
    magnitude_side = negative ? -side : side;
    exponent = mpfr_get_exp(scaled);
    if(magnitude_side < 0 &&
       mpfr_cmp_ui_2exp(scaled, 1UL, exponent - 1) == 0)
        exponent--;
    if(exponent > 128) {
        mpfr_clear(scaled);
        return vu_overflow_value(data_type, round_mode, negative);
    }
    shift = (long)exponent - (long)fraction_bits - 1L;
    if(shift < -126L - (long)fraction_bits)
        shift = -126L - (long)fraction_bits;
    mpfr_mul_2si(scaled, scaled, -shift, MPFR_RNDN);
    significand = mpfr_get_ui(scaled, MPFR_RNDD);
    mpfr_sub_ui(scaled, scaled, significand, MPFR_RNDN);
    fraction_nonzero = !mpfr_zero_p(scaled);
    halfway = mpfr_cmp_d(scaled, 0.5);
    if(!fraction_nonzero && magnitude_side != 0) {
        fraction_nonzero = 1;
        if(magnitude_side < 0) {
            significand--;
            halfway = 1;
        }
    } else if(halfway == 0) {
        halfway = magnitude_side;
    }
    switch(round_mode) {
    case 1: increment = 0; break;
    case 2: increment = negative && fraction_nonzero; break;
    case 3: increment = !negative && fraction_nonzero; break;
    case 4: increment = halfway >= 0; break;
    case 5:
        increment = halfway > 0 || (halfway == 0 && !(significand & 1UL));
        break;
    default:
        increment = halfway > 0 || (halfway == 0 && (significand & 1UL));
        break;
    }
    significand += (unsigned long)increment;
    mpfr_clear(scaled);
    if(significand < hidden)
        return sign | (uint32_t)significand;
    if(significand >= 2UL * hidden) {
        significand >>= 1;
        shift++;
    }
    exponent = shift + (long)fraction_bits + 127L;
    if(exponent >= 255)
        return sign | (data_type ? 0x7f80U : 0x7f800000U);
    return sign | ((uint32_t)exponent << fraction_bits) |
           (uint32_t)(significand - hidden);
}

enum vu_math_operation {
    VU_ADD, VU_SUB, VU_MUL, VU_DIV, VU_FMA,
    VU_SIN, VU_COS, VU_TANH, VU_SIGMOID, VU_EXP, VU_EXP2,
    VU_LOG, VU_LOG2, VU_SQRT, VU_RCP, VU_RSQRT
};

static int vu_mpfr_evaluate(mpfr_ptr result, enum vu_math_operation operation,
                            mpfr_srcptr a, mpfr_srcptr b, mpfr_srcptr c,
                            mpfr_rnd_t rounding)
{
    mpfr_t temporary;
    mpfr_rnd_t inverse;
    int inexact;

    switch(operation) {
    case VU_ADD: return mpfr_add(result, a, b, rounding);
    case VU_SUB: return mpfr_sub(result, a, b, rounding);
    case VU_MUL: return mpfr_mul(result, a, b, rounding);
    case VU_DIV: return mpfr_div(result, a, b, rounding);
    case VU_FMA: return mpfr_fma(result, a, b, c, rounding);
    case VU_SIN: return mpfr_sin(result, a, rounding);
    case VU_COS: return mpfr_cos(result, a, rounding);
    case VU_TANH: return mpfr_tanh(result, a, rounding);
    case VU_EXP: return mpfr_exp(result, a, rounding);
    case VU_EXP2: return mpfr_exp2(result, a, rounding);
    case VU_LOG: return mpfr_log(result, a, rounding);
    case VU_LOG2: return mpfr_log2(result, a, rounding);
    case VU_SQRT: return mpfr_sqrt(result, a, rounding);
    case VU_RCP: return mpfr_ui_div(result, 1UL, a, rounding);
    case VU_RSQRT: return mpfr_rec_sqrt(result, a, rounding);
    case VU_SIGMOID:
        mpfr_init2(temporary, mpfr_get_prec(result));
        inverse = rounding == MPFR_RNDD ? MPFR_RNDU : MPFR_RNDD;
        mpfr_neg(temporary, a, MPFR_RNDN);
        inexact = mpfr_exp(temporary, temporary, inverse) != 0;
        inexact |= mpfr_add_ui(temporary, temporary, 1UL, inverse) != 0;
        inexact |= mpfr_ui_div(result, 1UL, temporary, rounding) != 0;
        mpfr_clear(temporary);
        return inexact;
    }
    abort();
}

static uint32_t vu_math_result(enum vu_math_operation operation,
                               uint32_t a_bits, uint32_t b_bits,
                               uint32_t c_bits, uint32_t data_type,
                               uint32_t round_mode)
{
    mpfr_t a, b, c, lower, upper;
    mpfr_prec_t precision = 64;
    uint32_t low_bits, high_bits;
    int low_inexact, high_inexact;

    mpfr_inits2(precision, a, b, c, lower, upper, (mpfr_ptr)0);
    mpfr_set_d(a, (double)vu_bits_to_fp32(a_bits), MPFR_RNDN);
    mpfr_set_d(b, (double)vu_bits_to_fp32(b_bits), MPFR_RNDN);
    mpfr_set_d(c, (double)vu_bits_to_fp32(c_bits), MPFR_RNDN);
    if(mpfr_number_p(a) &&
       (operation == VU_EXP || operation == VU_EXP2 ||
        operation == VU_SIGMOID || operation == VU_TANH) &&
       (mpfr_cmp_si(a, 256L) > 0 || mpfr_cmp_si(a, -256L) < 0)) {
        if(operation == VU_TANH) {
            int negative = mpfr_sgn(a) < 0;
            mpfr_set_si(lower, negative ? -1L : 1L, MPFR_RNDN);
            low_bits = vu_mpfr_to_value(lower, data_type, round_mode,
                                        negative ? 1 : -1);
        } else if(operation == VU_SIGMOID && mpfr_sgn(a) > 0) {
            mpfr_set_ui(lower, 1UL, MPFR_RNDN);
            low_bits = vu_mpfr_to_value(lower, data_type, round_mode, -1);
        } else {
            mpfr_set_ui_2exp(lower, 1UL, mpfr_sgn(a) > 0 ? 512 : -512,
                             MPFR_RNDN);
            low_bits = vu_mpfr_to_value(lower, data_type, round_mode, 0);
        }
    } else {
        for(;;) {
            mpfr_set_prec(lower, precision);
            mpfr_set_prec(upper, precision);
            low_inexact = vu_mpfr_evaluate(lower, operation, a, b, c,
                                            MPFR_RNDD);
            high_inexact = vu_mpfr_evaluate(upper, operation, a, b, c,
                                             MPFR_RNDU);
            if(mpfr_zero_p(lower) && mpfr_zero_p(upper) &&
               !low_inexact && !high_inexact) {
                low_bits = vu_mpfr_to_value(round_mode == 2U ? lower : upper,
                                             data_type, round_mode, 0);
                break;
            }
            /* Inexact bounds are open, including when an endpoint is a rounding tie. */
            low_bits = vu_mpfr_to_value(lower, data_type, round_mode,
                                         low_inexact ? 1 : 0);
            high_bits = vu_mpfr_to_value(upper, data_type, round_mode,
                                          high_inexact ? -1 : 0);
            if(low_bits == high_bits)
                break;
            precision *= 2;
        }
    }
    mpfr_clears(a, b, c, lower, upper, (mpfr_ptr)0);
    return low_bits;
}

static uint32_t vu_minmax(uint32_t src1,
                          uint32_t src2,
                          uint32_t data_type,
                          uint32_t is_max,
                          uint32_t round_mode)
{
    uint32_t a_bits;
    uint32_t b_bits;
    float a;
    float b;

    (void)round_mode;
    a_bits = vu_value_to_fp32(src1, data_type);
    b_bits = vu_value_to_fp32(src2, data_type);

    if(vu_fp32_is_nan_bits(a_bits) && vu_fp32_is_nan_bits(b_bits))
        return data_type ? UINT32_C(0x7fc0) : UINT32_C(0x7fc00000);
    if(vu_fp32_is_nan_bits(a_bits))
        return src2;
    if(vu_fp32_is_nan_bits(b_bits))
        return src1;

    if(((a_bits & UINT32_C(0x7fffffff)) == 0U) &&
       ((b_bits & UINT32_C(0x7fffffff)) == 0U)) {
        uint32_t result_bits;
        if(is_max)
            result_bits = a_bits & b_bits;
        else
            result_bits = a_bits | b_bits;
        return data_type ? (result_bits >> 16) : result_bits;
    }

    a = vu_bits_to_fp32(a_bits);
    b = vu_bits_to_fp32(b_bits);
    if(is_max)
        return a > b ? src1 : src2;
    return a < b ? src1 : src2;
}

uint32_t vu_fp_alu(uint32_t opcode,
                   uint32_t src1,
                   uint32_t src2,
                   uint32_t src3,
                   uint32_t data_type,
                   uint32_t round_mode)
{
    uint32_t a = vu_value_to_fp32(src1, data_type);
    uint32_t b = vu_value_to_fp32(src2, data_type);
    uint32_t c = vu_value_to_fp32(src3, data_type);
    uint32_t sign_mask;
    enum vu_math_operation operation;

    switch(opcode & 0xffU) {
    case 0x01:
    case 0x02:
        operation = VU_ADD;
        break;
    case 0x03:
    case 0x04:
        return vu_math_result(VU_SUB, b, a, 0U, data_type, round_mode);
    case 0x05:
        operation = VU_SUB;
        break;
    case 0x06:
    case 0x07:
        operation = VU_MUL;
        break;
    case 0x08:
        return vu_math_result(VU_DIV, b, a, 0U, data_type, round_mode);
    case 0x10:
    case 0x11:
        return vu_minmax(src1, src2, data_type, 0U, round_mode);
    case 0x12:
    case 0x13:
        return vu_minmax(src1, src2, data_type, 1U, round_mode);
    case 0x30:
    case 0x31:
        operation = VU_FMA;
        break;
    case 0x32:
    case 0x33:
        operation = VU_FMA;
        a ^= 0x80000000U;
        c ^= 0x80000000U;
        break;
    case 0x34:
    case 0x35:
        operation = VU_FMA;
        c ^= 0x80000000U;
        break;
    case 0x36:
    case 0x37:
        operation = VU_FMA;
        a ^= 0x80000000U;
        break;
    case 0x40:
    case 0x41:
        sign_mask = data_type ? UINT32_C(0x8000) : UINT32_C(0x80000000);
        return (src2 & ~sign_mask) | (src1 & sign_mask);
    case 0x42:
    case 0x43:
        sign_mask = data_type ? UINT32_C(0x8000) : UINT32_C(0x80000000);
        return (src2 & ~sign_mask) | ((~src1) & sign_mask);
    case 0x44:
    case 0x45:
        sign_mask = data_type ? UINT32_C(0x8000) : UINT32_C(0x80000000);
        return (src2 & ~sign_mask) | ((src2 ^ src1) & sign_mask);
    default:
        return src2;
    }

    return vu_math_result(operation, a, b, c, data_type, round_mode);
}

uint32_t vu_fp_compare(uint32_t opcode,
                       uint32_t src1,
                       uint32_t src2,
                       uint32_t data_type)
{
    uint32_t a_bits;
    uint32_t b_bits;
    float a;
    float b;

    a_bits = vu_value_to_fp32(src1, data_type);
    b_bits = vu_value_to_fp32(src2, data_type);
    if(vu_fp32_is_nan_bits(a_bits) || vu_fp32_is_nan_bits(b_bits))
        return (opcode == 0x52U || opcode == 0x53U) ? 1U : 0U;

    a = vu_bits_to_fp32(a_bits);
    b = vu_bits_to_fp32(b_bits);
    switch(opcode & 0xffU) {
    case 0x50:
    case 0x51:
        return b == a;
    case 0x52:
    case 0x53:
        return b != a;
    case 0x54:
    case 0x55:
        return b < a;
    case 0x56:
    case 0x57:
        return b <= a;
    case 0x58:
        return b > a;
    case 0x59:
        return b >= a;
    default:
        return 0U;
    }
}

uint32_t vu_fp_class(uint32_t src, uint32_t data_type, uint32_t class_mask)
{
    uint32_t sign;
    uint32_t exponent;
    uint32_t fraction;
    uint32_t exp_mask;
    uint32_t frac_mask;
    uint32_t quiet_mask;
    uint32_t class_bit;

    if(data_type) {
        sign = (src >> 15) & 1U;
        exp_mask = UINT32_C(0x7f80);
        frac_mask = UINT32_C(0x007f);
        quiet_mask = UINT32_C(0x0040);
        exponent = src & exp_mask;
        fraction = src & frac_mask;
    } else {
        sign = src >> 31;
        exp_mask = UINT32_C(0x7f800000);
        frac_mask = UINT32_C(0x007fffff);
        quiet_mask = UINT32_C(0x00400000);
        exponent = src & exp_mask;
        fraction = src & frac_mask;
    }

    if(exponent == exp_mask) {
        if(fraction == 0U)
            class_bit = sign ? 0U : 7U;
        else
            class_bit = (fraction & quiet_mask) ? 9U : 8U;
    } else if(exponent == 0U) {
        if(fraction == 0U)
            class_bit = sign ? 3U : 4U;
        else
            class_bit = sign ? 2U : 5U;
    } else {
        class_bit = sign ? 1U : 6U;
    }

    return (class_mask >> class_bit) & 1U;
}

uint32_t vu_fp_vsfu(uint32_t opcode,
                    uint32_t src,
                    uint32_t data_type,
                    uint32_t round_mode)
{
    enum vu_math_operation operation;

    switch(opcode & 0xffU) {
    case 0x01: operation = VU_SIN; break;
    case 0x02: operation = VU_COS; break;
    case 0x03: operation = VU_TANH; break;
    case 0x04: operation = VU_SIGMOID; break;
    case 0x05: operation = VU_EXP; break;
    case 0x06: operation = VU_EXP2; break;
    case 0x07: operation = VU_LOG; break;
    case 0x08: operation = VU_LOG2; break;
    case 0x09: operation = VU_SQRT; break;
    case 0x0a: operation = VU_RCP; break;
    case 0x0b: operation = VU_RSQRT; break;
    case 0x0c:
        /* The coefficient interface is unspecified; this remains an identity placeholder. */
        return src;
    default:
        return src;
    }
    return vu_math_result(operation, vu_value_to_fp32(src, data_type),
                           0U, 0U, data_type, round_mode);
}

uint32_t vu_fp_sexe(uint32_t opcode, uint32_t src1, uint32_t src2)
{
    enum vu_math_operation operation;

    switch(opcode & 0xffU) {
    case 0x01: operation = VU_ADD; break;
    case 0x02: operation = VU_SUB; break;
    case 0x03: operation = VU_MUL; break;
    case 0x04: operation = VU_DIV; break;
    case 0x05: operation = VU_SQRT; break;
    case 0x06: operation = VU_RSQRT; break;
    case 0x07: operation = VU_RCP; break;
    default: return src1;
    }
    return vu_math_result(operation, src1, src2, 0U, 0U, 0U);
}

struct vu_sum {
    mpfr_t value;
    int all_negative_zero;
};

void *vu_sum_create(uint32_t initial_fp32)
{
    struct vu_sum *sum = (struct vu_sum *)malloc(sizeof(*sum));

    if(sum == NULL)
        abort();
    /* 512 bits hold an exact sum of 16384 finite FP32 values across their full exponent range. */
    mpfr_init2(sum->value, 512);
    mpfr_set_d(sum->value, (double)vu_bits_to_fp32(initial_fp32), MPFR_RNDN);
    sum->all_negative_zero = initial_fp32 == 0x80000000U;
    return sum;
}

void vu_sum_add(void *context, uint32_t fp32_bits)
{
    struct vu_sum *sum = (struct vu_sum *)context;
    mpfr_t term;

    mpfr_init2(term, 24);
    mpfr_set_d(term, (double)vu_bits_to_fp32(fp32_bits), MPFR_RNDN);
    mpfr_add(sum->value, sum->value, term, MPFR_RNDD);
    sum->all_negative_zero &= fp32_bits == 0x80000000U;
    mpfr_clear(term);
}

uint32_t vu_sum_finish(void *context, uint32_t round_mode)
{
    struct vu_sum *sum = (struct vu_sum *)context;
    uint32_t result;

    if(mpfr_zero_p(sum->value) && round_mode != 2U && !sum->all_negative_zero)
        mpfr_set_zero(sum->value, 1);
    result = vu_mpfr_to_value(sum->value, 0U, round_mode, 0);
    mpfr_clear(sum->value);
    free(sum);
    return result;
}

uint32_t vu_load_convert(uint32_t opcode,
                         uint32_t raw,
                         uint32_t data_type,
                         uint32_t round_mode)
{
    uint32_t fp32_bits;

    switch(opcode & 0xffU) {
    case 0x01:
    case 0x02: /* MXFP8 element path; block scale is handled by the caller. */
        fp32_bits = vu_fp8e4m3_to_fp32(raw);
        break;
    case 0x03:
        fp32_bits = vu_bf16_to_fp32(raw);
        break;
    case 0x04:
        fp32_bits = raw;
        break;
    default:
        return raw;
    }
    return data_type ? vu_fp32_to_bf16(fp32_bits, round_mode) : fp32_bits;
}

uint32_t vu_store_convert(uint32_t opcode,
                          uint32_t value,
                          uint32_t data_type,
                          uint32_t round_mode)
{
    uint32_t fp32_bits;

    fp32_bits = vu_value_to_fp32(value, data_type);
    switch(opcode & 0xffU) {
    case 0x01:
    case 0x02: /* MXFP8 element path; block scale is handled by the caller. */
        return vu_fp32_to_fp8e4m3(fp32_bits, round_mode);
    case 0x03:
        return data_type ? (value & UINT32_C(0xffff)) :
                           vu_fp32_to_bf16(fp32_bits, round_mode);
    case 0x04:
        return fp32_bits;
    default:
        return value;
    }
}

/* MXFP8 block-shared ScaleFactor support. The e8m0 scale byte encodes a
 * power of two: 2^(e8m0 - 127); 0xff is the e8m0 NaN encoding. The CM-side
 * data<->scale address mapping is handled by the caller. */
static float vu_e8m0_to_float(uint32_t scale)
{
    if((scale & 0xffU) == 0xffU)
        return NAN;

    return exp2f((float)((int)(scale & 0xffU) - 127));
}

/* Derive the block-shared e8m0 scale from the block's max |element| (FP32
 * bits): scale = 2^(log2(max) - E4M3_EMAX(=8)) so the largest element lands
 * inside the e4m3 range. round_up selects ceil(log2) instead of floor(log2)
 * for a non-power-of-two max, mirroring SU_op.MXFP8_SCALE_ROUND. An
 * all-zero or NaN block keeps the neutral scale 2^0. */
uint32_t vu_mxfp8_scale_encode(uint32_t max_abs_bits, uint32_t round_up)
{
    int exponent;
    uint32_t fraction;
    int log2_max;
    int scale_biased;

    max_abs_bits &= UINT32_C(0x7fffffff);
    if(max_abs_bits == 0U || vu_fp32_is_nan_bits(max_abs_bits))
        return 127U;

    exponent = (int)((max_abs_bits >> 23) & 0xffU);
    fraction = max_abs_bits & UINT32_C(0x007fffff);
    if(exponent == 0) {
        /* Subnormal max: value = fraction * 2^-149. */
        int msb = 22;

        while(msb > 0 && !((fraction >> msb) & 1U))
            msb--;
        log2_max = msb - 149;
        if(round_up && fraction != (UINT32_C(1) << msb))
            log2_max++;
    } else {
        log2_max = exponent - 127;
        if(round_up && fraction != 0U)
            log2_max++;
    }

    scale_biased = log2_max - 8 + 127;
    if(scale_biased < 0)
        scale_biased = 0;
    if(scale_biased > 254)
        scale_biased = 254;
    return (uint32_t)scale_biased;
}

uint32_t vu_mxfp8_load_convert(uint32_t raw,
                               uint32_t scale,
                               uint32_t data_type,
                               uint32_t round_mode)
{
    float value;
    uint32_t fp32_bits;

    value = vu_bits_to_fp32(vu_fp8e4m3_to_fp32(raw)) * vu_e8m0_to_float(scale);
    fp32_bits = vu_fp32_to_bits(value);
    return data_type ? vu_fp32_to_bf16(fp32_bits, round_mode) : fp32_bits;
}

uint32_t vu_mxfp8_store_convert(uint32_t value,
                                uint32_t scale,
                                uint32_t data_type,
                                uint32_t round_mode)
{
    float scaled;

    scaled = vu_bits_to_fp32(vu_value_to_fp32(value, data_type)) /
             vu_e8m0_to_float(scale);
    return vu_fp32_to_fp8e4m3(vu_fp32_to_bits(scaled), round_mode);
}

/* Compatibility entry points for earlier focused vfadd/vfmin tests. */
uint32_t vu_fp32_add(uint32_t src1, uint32_t src2, uint32_t round_mode)
{
    return vu_fp_alu(0x01U, src1, src2, 0U, 0U, round_mode);
}

uint32_t vu_fp32_min(uint32_t src1, uint32_t src2, uint32_t round_mode)
{
    return vu_fp_alu(0x10U, src1, src2, 0U, 0U, round_mode);
}
