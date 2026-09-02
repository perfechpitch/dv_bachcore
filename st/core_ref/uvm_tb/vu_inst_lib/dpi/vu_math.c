#include "vu_math.h"
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

uint32_t vu_fp32_add(uint32_t src1, uint32_t src2, uint32_t round_mode)
{
    float result;
    /* The first backend uses the host C FP environment. round_mode is kept in
     * the ABI for the architectural implementation; this is not yet a
     * bit-exact implementation of every VU rounding mode. */
    (void)round_mode;
    result = vu_bits_to_fp32(src1) + vu_bits_to_fp32(src2);
    return vu_fp32_to_bits(result);
}
