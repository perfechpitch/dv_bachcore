#include "vu_math.h"

#include <float.h>
#include <math.h>
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

static float vu_value_to_float(uint32_t value, uint32_t data_type)
{
    return vu_bits_to_fp32(vu_value_to_fp32(value, data_type));
}

static uint32_t vu_float_to_value(float value,
                                  uint32_t data_type,
                                  uint32_t round_mode)
{
    uint32_t bits;

    bits = vu_fp32_to_bits(value);
    return data_type ? vu_fp32_to_bf16(bits, round_mode) : bits;
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
    float a;
    float b;
    float c;
    float result;
    uint32_t sign_mask;

    a = vu_value_to_float(src1, data_type);
    b = vu_value_to_float(src2, data_type);
    c = vu_value_to_float(src3, data_type);
    result = 0.0f;

    switch(opcode & 0xffU) {
    case 0x01:
    case 0x02:
        result = b + a;
        break;
    case 0x03:
    case 0x04:
        result = b - a;
        break;
    case 0x05:
        result = a - b;
        break;
    case 0x06:
    case 0x07:
        result = b * a;
        break;
    case 0x08:
        result = b / a;
        break;
    case 0x10:
    case 0x11:
        return vu_minmax(src1, src2, data_type, 0U, round_mode);
    case 0x12:
    case 0x13:
        return vu_minmax(src1, src2, data_type, 1U, round_mode);
    case 0x30:
    case 0x31:
        result = fmaf(a, b, c);
        break;
    case 0x32:
    case 0x33:
        result = fmaf(-a, b, -c);
        break;
    case 0x34:
    case 0x35:
        result = fmaf(a, b, -c);
        break;
    case 0x36:
    case 0x37:
        result = fmaf(-a, b, c);
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

    return vu_float_to_value(result, data_type, round_mode);
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
    float value;
    float result;

    value = vu_value_to_float(src, data_type);
    switch(opcode & 0xffU) {
    case 0x01: result = sinf(value); break;
    case 0x02: result = cosf(value); break;
    case 0x03: result = tanhf(value); break;
    case 0x04: result = 1.0f / (1.0f + expf(-value)); break;
    case 0x05: result = expf(value); break;
    case 0x06: result = exp2f(value); break;
    case 0x07: result = logf(value); break;
    case 0x08: result = log2f(value); break;
    case 0x09: result = sqrtf(value); break;
    case 0x0a: result = 1.0f / value; break;
    case 0x0b: result = 1.0f / sqrtf(value); break;
    case 0x0c:
        /* The architecture document does not define coefficient registers.
         * Identity is the deterministic fallback until that interface exists. */
        result = value;
        break;
    default:
        result = value;
        break;
    }
    return vu_float_to_value(result, data_type, round_mode);
}

uint32_t vu_fp_sexe(uint32_t opcode, uint32_t src1, uint32_t src2)
{
    float a;
    float b;
    float result;

    a = vu_bits_to_fp32(src1);
    b = vu_bits_to_fp32(src2);
    switch(opcode & 0xffU) {
    case 0x01: result = a + b; break;
    case 0x02: result = a - b; break;
    case 0x03: result = a * b; break;
    case 0x04: result = a / b; break;
    case 0x05: result = sqrtf(a); break;
    case 0x06: result = 1.0f / sqrtf(a); break;
    case 0x07: result = 1.0f / a; break;
    default: return src1;
    }
    return vu_fp32_to_bits(result);
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

/* Compatibility entry points for earlier focused vfadd/vfmin tests. */
uint32_t vu_fp32_add(uint32_t src1, uint32_t src2, uint32_t round_mode)
{
    return vu_fp_alu(0x01U, src1, src2, 0U, 0U, round_mode);
}

uint32_t vu_fp32_min(uint32_t src1, uint32_t src2, uint32_t round_mode)
{
    return vu_fp_alu(0x10U, src1, src2, 0U, 0U, round_mode);
}
