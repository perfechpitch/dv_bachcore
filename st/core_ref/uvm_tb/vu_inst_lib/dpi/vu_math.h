#ifndef VU_MATH_H
#define VU_MATH_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
uint32_t vu_bf16_to_fp32(uint32_t value);
uint32_t vu_fp32_to_bf16(uint32_t bits, uint32_t round_mode);
uint32_t vu_fp8e4m3_to_fp32(uint32_t raw);
uint32_t vu_fp32_to_fp8e4m3(uint32_t bits, uint32_t round_mode);
uint32_t vu_fp_alu(uint32_t opcode, uint32_t src1, uint32_t src2,
                   uint32_t src3, uint32_t data_type, uint32_t round_mode);
uint32_t vu_fp_compare(uint32_t opcode, uint32_t src1, uint32_t src2,
                       uint32_t data_type);
uint32_t vu_fp_class(uint32_t src, uint32_t data_type, uint32_t class_mask);
uint32_t vu_fp_vsfu(uint32_t opcode, uint32_t src, uint32_t data_type,
                    uint32_t round_mode);
uint32_t vu_fp_sexe(uint32_t opcode, uint32_t src1, uint32_t src2);
uint32_t vu_load_convert(uint32_t opcode, uint32_t raw, uint32_t data_type,
                         uint32_t round_mode);
uint32_t vu_store_convert(uint32_t opcode, uint32_t value, uint32_t data_type,
                          uint32_t round_mode);
uint32_t vu_fp32_add(uint32_t src1, uint32_t src2, uint32_t round_mode);
uint32_t vu_fp32_min(uint32_t src1, uint32_t src2, uint32_t round_mode);
#ifdef __cplusplus
}
#endif
#endif
