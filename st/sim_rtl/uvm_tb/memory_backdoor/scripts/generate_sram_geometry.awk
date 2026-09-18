function fail(message) {
  print "ERROR: " message > "/dev/stderr"
  failed = 1
}

function parse_uint(name, value) {
  if (value !~ /^[0-9]+$/) {
    fail(name " must be a non-negative decimal integer, got '" value "'")
    return -1
  }
  return value + 0
}

function is_power_of_two(value) {
  if (value < 1)
    return 0
  while ((value % 2) == 0)
    value /= 2
  return value == 1
}

BEGIN {
  failed = 0
  if (address_interleave == "")
    address_interleave = 1
  if (address_interleave !~ /^[01]$/) {
    fail("address_interleave must be exactly 0 or 1")
    address_interleave = 1
  }
  else
    address_interleave += 0
  sram_count = parse_uint("SRAM_COUNT", sram_count)
  bank_count = parse_uint("SRAM_BANK_COUNT", bank_count)
  access_width = parse_uint("data_width", access_width)
  interleave_bytes = parse_uint("interleave granularity bytes",
                                interleave_bytes)
  interleave_words = parse_uint("interleave granularity words",
                                interleave_words)
  if (sram_count < 1)
    fail("SRAM_COUNT must be greater than zero")
  if (bank_count < 1)
    fail("SRAM_BANK_COUNT must be greater than zero")
  word_bytes = 0
  if ((access_width < 8) || ((access_width % 8) != 0) ||
      (access_width > 1024))
    fail("data_width must be a byte-aligned bit count in [8:1024]")
  else
    word_bytes = access_width / 8
  if ((word_bytes > 0) && (interleave_bytes < word_bytes))
    fail("interleave granularity must be at least one data word (" \
         word_bytes " bytes)")
  else if ((word_bytes > 0) && ((interleave_bytes % word_bytes) != 0))
    fail("interleave granularity must be a multiple of the data word size (" \
         word_bytes " bytes)")
  if (interleave_words < 1)
    fail("interleave granularity must contain at least one word")
  if (!is_power_of_two(interleave_words))
    fail("interleave granularity words must be a power of two")
  if ((word_bytes > 0) &&
      (interleave_bytes != (interleave_words * word_bytes)))
    fail("interleave granularity byte/word values are inconsistent")

  expected_target_count = sram_count * bank_count
  path_count = split(hdl_paths, paths, ",")
  capacity_count = split(capacity_list, capacities, ",")
  sram_index_count = split(sram_indices, srams, ",")
  bank_index_count = split(bank_indices, banks, ",")
  if (path_count != expected_target_count ||
      path_count != capacity_count ||
      path_count != sram_index_count ||
      path_count != bank_index_count)
    fail("hdl_path and structural metadata counts must equal SRAM_COUNT * SRAM_BANK_COUNT")

  for (target_number = 1; target_number <= path_count; target_number++) {
    capacity = parse_uint("capacity for memory item " target_number,
                          capacities[target_number])
    sram_index = parse_uint("SRAM index for memory item " target_number,
                            srams[target_number])
    bank_index = parse_uint("bank index for memory item " target_number,
                            banks[target_number])
    expected_sram = int((target_number - 1) / bank_count)
    expected_bank = (target_number - 1) % bank_count
    expected_path = "tb_top.dut.gen_sram[" expected_sram \
                    "].u_interleaved_sram.gen_bank[" expected_bank \
                    "].u_sram.sram"

    if (capacity < 1)
      fail("bank capacity must be greater than zero")
    if ((address_interleave == 1) && (interleave_words > 0) &&
        ((capacity % interleave_words) != 0))
      fail("bank capacity must be divisible by interleave granularity")
    if (sram_index != expected_sram || bank_index != expected_bank)
      fail("memory items must be ordered by SRAM, then by bank")
    if (paths[target_number] != expected_path)
      fail("memory item " target_number " hdl_path must be '" \
           expected_path "'")

    if (bank_index == 0)
      common_capacity[sram_index] = capacity
    else if (capacity != common_capacity[sram_index])
      fail("all banks within SRAM " sram_index " must have equal capacity")

    geometry_words[sram_index SUBSEP bank_index] = capacity
    sram_total_words[sram_index] += capacity
  }

  if (failed)
    exit 1

  next_sram_base_word = 0
  for (sram_index = 0; sram_index < sram_count; sram_index++) {
    sram_base_word[sram_index] = next_sram_base_word
    next_sram_base_word += sram_total_words[sram_index]
  }

  print "// Generated from the selected memory configuration. Do not edit."
  print "package sram_geometry_pkg;"
  print "  localparam int unsigned SRAM_COUNT = " sram_count ";"
  print "  localparam int unsigned SRAM_BANK_COUNT = " bank_count ";"
  print "  localparam int unsigned SRAM_DATA_WIDTH = " access_width ";"
  print "  localparam int unsigned SRAM_WORD_BYTES = " word_bytes ";"
  print "  localparam bit SRAM_ADDRESS_INTERLEAVE = 1'b" \
        address_interleave ";"
  print "  localparam int unsigned SRAM_INTERLEAVE_GRANULARITY_BYTES = " \
        interleave_bytes ";"
  print "  localparam int unsigned SRAM_INTERLEAVE_GRANULARITY_WORDS = " \
        interleave_words ";"
  print ""
  print "  function automatic int unsigned sram_words(input int unsigned sram_index);"
  print "    case (sram_index)"
  for (sram_index = 0; sram_index < sram_count; sram_index++)
    print "      " sram_index ": sram_words = " sram_total_words[sram_index] ";"
  print "      default: sram_words = 0;"
  print "    endcase"
  print "  endfunction"
  print ""
  print "  function automatic longint unsigned sram_base_word_address("
  print "    input int unsigned sram_index"
  print "  );"
  print "    case (sram_index)"
  for (sram_index = 0; sram_index < sram_count; sram_index++)
    print "      " sram_index ": sram_base_word_address = " \
          sram_base_word[sram_index] ";"
  print "      default: sram_base_word_address = 0;"
  print "    endcase"
  print "  endfunction"
  print ""
  print "  function automatic int unsigned bank_words("
  print "    input int unsigned sram_index,"
  print "    input int unsigned bank_index"
  print "  );"
  print "    bank_words = 0;"
  for (sram_index = 0; sram_index < sram_count; sram_index++) {
    for (bank_index = 0; bank_index < bank_count; bank_index++) {
      keyword = ((sram_index == 0) && (bank_index == 0)) ? "if" : "else if"
      print "    " keyword " ((sram_index == " sram_index \
            ") && (bank_index == " bank_index "))"
      print "      bank_words = " \
            geometry_words[sram_index SUBSEP bank_index] ";"
    }
  }
  print "  endfunction"
  print "endpackage"
}
