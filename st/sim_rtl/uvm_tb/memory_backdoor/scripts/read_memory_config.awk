function trim(value) {
  sub(/^[ \t]+/, "", value)
  sub(/[ \t]+$/, "", value)
  return value
}

function unquote(value, first_char, last_char) {
  first_char = substr(value, 1, 1)
  last_char = substr(value, length(value), 1)
  if (length(value) >= 2 && first_char == last_char &&
      (first_char == "\"" || first_char == "'"))
    return substr(value, 2, length(value) - 2)
  return value
}

function report_error(message) {
  print "ERROR: " FILENAME ": " message > "/dev/stderr"
  failed = 1
}

function append_csv(current, value) {
  if (current == "")
    return value
  return current "," value
}

function validate_path(path) {
  if (path !~ /^[A-Za-z_$][A-Za-z0-9_$]*(\[[0-9]+\])?(\.[A-Za-z_$][A-Za-z0-9_$]*(\[[0-9]+\])?)+$/) {
    report_error("invalid hdl_path '" path "'")
    return 0
  }
  return 1
}

function validate_positive_uint(name, value) {
  if (value !~ /^[1-9][0-9]*$/) {
    report_error(name " must be a positive decimal integer")
    return 0
  }
  return 1
}

function data_width_to_bits(name, value, upper_value, bits) {
  upper_value = toupper(value)
  if (upper_value ~ /^[1-9][0-9]*$/)
    return upper_value + 0
  if (upper_value ~ /^[1-9][0-9]*BITS?$/) {
    bits = upper_value
    sub(/BITS?$/, "", bits)
    return bits + 0
  }
  report_error(name " must be a positive bit width such as 32bit or 64bit")
  return 0
}

function capacity_to_words(name, value, width, upper_value, number,
                           multiplier, bytes, word_bytes) {
  if (value ~ /^[1-9][0-9]*$/)
    return value + 0

  upper_value = toupper(value)
  multiplier = 0
  if (upper_value ~ /^[1-9][0-9]*B$/) {
    number = substr(upper_value, 1, length(upper_value) - 1) + 0
    multiplier = 1
  }
  else if (upper_value ~ /^[1-9][0-9]*(KB|KIB)$/) {
    number = upper_value
    sub(/K(I)?B$/, "", number)
    multiplier = 1024
  }
  else if (upper_value ~ /^[1-9][0-9]*(MB|MIB)$/) {
    number = upper_value
    sub(/M(I)?B$/, "", number)
    multiplier = 1024 * 1024
  }
  else if (upper_value ~ /^[1-9][0-9]*(GB|GIB)$/) {
    number = upper_value
    sub(/G(I)?B$/, "", number)
    multiplier = 1024 * 1024 * 1024
  }
  else {
    report_error(name " must be a positive word count or a size such as 2KB")
    return 0
  }

  if ((width < 8) || ((width % 8) != 0)) {
    report_error(name " uses byte units but data_width is not byte-aligned")
    return 0
  }
  bytes = number * multiplier
  word_bytes = width / 8
  if ((bytes % word_bytes) != 0) {
    report_error(name " is not divisible by the configured word size")
    return 0
  }
  return bytes / word_bytes
}

function size_to_bytes(name, value, upper_value, number, multiplier) {
  upper_value = toupper(value)
  multiplier = 0
  if (upper_value ~ /^[1-9][0-9]*B$/) {
    number = substr(upper_value, 1, length(upper_value) - 1) + 0
    multiplier = 1
  }
  else if (upper_value ~ /^[1-9][0-9]*(KB|KIB)$/) {
    number = upper_value
    sub(/K(I)?B$/, "", number)
    multiplier = 1024
  }
  else if (upper_value ~ /^[1-9][0-9]*(MB|MIB)$/) {
    number = upper_value
    sub(/M(I)?B$/, "", number)
    multiplier = 1024 * 1024
  }
  else {
    report_error(name " must use a byte size such as 4B, 16B, or 1KB")
    return 0
  }
  return number * multiplier
}

function is_power_of_two(value) {
  if (value < 1)
    return 0
  while ((value % 2) == 0)
    value /= 2
  return value == 1
}

function parse_item_field(text, item_number, separator, key, value) {
  separator = index(text, ":")
  if (separator == 0) {
    report_error("line " FNR ": expected key: value")
    return
  }
  key = trim(substr(text, 1, separator - 1))
  value = unquote(trim(substr(text, separator + 1)))
  if (key != "hdl_path") {
    report_error("line " FNR ": memory items only support hdl_path; found '" \
                 key "'")
    return
  }
  if ((item_number SUBSEP key) in item_seen) {
    report_error("line " FNR ": duplicate memory key '" key "'")
    return
  }
  item_seen[item_number SUBSEP key] = 1
  item[item_number SUBSEP key] = value
}

BEGIN {
  failed = 0
  item_count = 0
  memories_seen = 0
  address_interleave = 1
  address_interleave_seen = 0
  if (expected_sram_count == "")
    expected_sram_count = 1
  if (expected_bank_count == "")
    expected_bank_count = 4
  validate_positive_uint("SRAM_COUNT", expected_sram_count)
  validate_positive_uint("SRAM_BANK_COUNT", expected_bank_count)
  access_width = 0
  data_width_seen = 0
  capacity_seen = 0
  interleave_granularity_seen = 0
  expected_sram_count += 0
  expected_bank_count += 0
  if (expected_sram_count != 1)
    report_error("this design requires exactly one SRAM")
  if (expected_bank_count != 4)
    report_error("this design requires exactly four banks; capacity is divided by 4")
}

{
  raw_line = $0
  sub(/#.*/, "", raw_line)
  if (trim(raw_line) == "")
    next

  match(raw_line, /^[ ]*/)
  indent = RLENGTH
  line = trim(raw_line)

  if (indent == 0) {
    separator = index(line, ":")
    if (separator == 0) {
      report_error("line " FNR ": expected key: value")
      next
    }
    key = trim(substr(line, 1, separator - 1))
    value = unquote(trim(substr(line, separator + 1)))
    if (key == "data_width") {
      if (data_width_seen)
        report_error("line " FNR ": duplicate data_width key")
      if (value == "")
        report_error("line " FNR ": data_width requires a bit width")
      else
        access_width = data_width_to_bits("data_width", value)
      data_width_seen = 1
      next
    }
    if (key == "capacity") {
      if (capacity_seen)
        report_error("line " FNR ": duplicate capacity key")
      if (value == "")
        report_error("line " FNR ": capacity requires a total SRAM size")
      else
        total_capacity_text = value
      capacity_seen = 1
      next
    }
    if (key == "address_interleave") {
      if (address_interleave_seen)
        report_error("line " FNR ": duplicate address_interleave key")
      if (value !~ /^[01]$/)
        report_error("line " FNR ": address_interleave must be exactly 0 or 1")
      else
        address_interleave = value + 0
      address_interleave_seen = 1
      next
    }
    if (key == "interleave_granularity") {
      if (interleave_granularity_seen)
        report_error("line " FNR ": duplicate interleave_granularity key")
      if (value == "")
        report_error("line " FNR ": interleave_granularity requires a byte size")
      interleave_granularity_text = value
      interleave_granularity_seen = 1
      next
    }
    if (key != "memories") {
      report_error("line " FNR ": YAML supports data_width, capacity, " \
                   "address_interleave, interleave_granularity, and one " \
                   "flat memories list")
      next
    }
    if (memories_seen)
      report_error("line " FNR ": duplicate memories key")
    if (value != "")
      report_error("line " FNR ": memories must be a YAML list")
    memories_seen = 1
    next
  }

  if (!memories_seen) {
    report_error("line " FNR ": unexpected indentation before memories")
    next
  }
  if (substr(line, 1, 1) == "-") {
    item_count++
    item_text = trim(substr(line, 2))
    if (item_text != "")
      parse_item_field(item_text, item_count)
  }
  else {
    if (item_count == 0) {
      report_error("line " FNR ": memory field appears before first list item")
      next
    }
    parse_item_field(line, item_count)
  }
}

END {
  expected_item_count = expected_sram_count * expected_bank_count
  if (!memories_seen)
    report_error("missing memories list")
  if (!data_width_seen)
    report_error("missing data_width key")
  if (!capacity_seen)
    report_error("missing capacity key")
  if (item_count != expected_item_count)
    report_error("configuration requires " expected_sram_count " SRAMs x " \
                 expected_bank_count " banks = " expected_item_count \
                 " items, but YAML contains " item_count)

  data_width_valid = 0
  if (data_width_seen &&
      ((access_width < 8) || ((access_width % 8) != 0) ||
       (access_width > 1024))) {
    report_error("data_width must be a byte-aligned bit count in [8:1024]")
    word_bytes = 0
  }
  else if (data_width_seen) {
    word_bytes = access_width / 8
    data_width_valid = 1
  }
  else
    word_bytes = 0
  if (!interleave_granularity_seen)
    interleave_granularity_text = word_bytes "B"
  interleave_granularity_bytes = size_to_bytes("interleave_granularity", interleave_granularity_text)
  granularity_shape_valid = 0
  if ((word_bytes != 0) && (interleave_granularity_bytes != 0)) {
    if (interleave_granularity_bytes < word_bytes)
      report_error("interleave_granularity (" interleave_granularity_bytes \
                   "B) must be at least one data word (" word_bytes \
                   "B for data_width " access_width "bit)")
    else if ((interleave_granularity_bytes % word_bytes) != 0)
      report_error("interleave_granularity must be a multiple of the word " \
                   "size (" word_bytes "B for data_width " access_width \
                   "bit)")
    else
      granularity_shape_valid = 1
  }
  if (granularity_shape_valid)
    interleave_granularity_words = interleave_granularity_bytes / word_bytes
  else
    interleave_granularity_words = 0
  if (granularity_shape_valid &&
      !is_power_of_two(interleave_granularity_words))
    report_error("interleave_granularity must contain a power-of-two number of words")

  if (capacity_seen && data_width_valid)
    total_capacity_words = capacity_to_words("capacity", total_capacity_text,
                                             access_width)
  else
    total_capacity_words = 0
  if (total_capacity_words >= 4294967296)
    report_error("capacity exceeds the 32-bit structural word-address limit")
  if ((total_capacity_words != 0) &&
      ((total_capacity_words % expected_bank_count) != 0))
    report_error("capacity (" total_capacity_words \
                 " words per SRAM) must be divisible by SRAM_BANK_COUNT (" \
                 expected_bank_count ")")
  if ((total_capacity_words != 0) &&
      ((total_capacity_words % expected_bank_count) == 0))
    bank_capacity_words = total_capacity_words / expected_bank_count
  else
    bank_capacity_words = 0
  if ((address_interleave == 1) &&
      (interleave_granularity_words != 0) &&
      (bank_capacity_words != 0) &&
      ((bank_capacity_words % interleave_granularity_words) != 0))
    report_error("capacity gives " bank_capacity_words \
                 " words per bank, which is not divisible by " \
                 "interleave_granularity (" interleave_granularity_words \
                 " words)")

  total_words = 0
  hdl_path_csv = capacity_csv = target_specs = ""
  bank_index_csv = sram_index_csv = ""

  for (item_number = 1; item_number <= item_count; item_number++) {
    path = item[item_number SUBSEP "hdl_path"]
    sram_index = int((item_number - 1) / expected_bank_count)
    bank_index = (item_number - 1) % expected_bank_count

    if (path == "")
      report_error("memory item " item_number " is missing hdl_path")
    else
      validate_path(path)
    capacity = bank_capacity_words

    sram_words[sram_index] += capacity
    total_words += capacity
    resolved_path[item_number] = path
    resolved_capacity[item_number] = capacity
    resolved_capacity_text[item_number] = capacity " words"
    resolved_sram_index[item_number] = sram_index
    resolved_bank_index[item_number] = bank_index
    hdl_path_csv = append_csv(hdl_path_csv, path)
    capacity_csv = append_csv(capacity_csv, capacity)
    sram_index_csv = append_csv(sram_index_csv, sram_index)
    bank_index_csv = append_csv(bank_index_csv, bank_index)
    target_specs = append_csv(target_specs,
                              path ":" capacity ":" access_width)
  }

  if (failed)
    exit 1

  output["access_width"] = access_width
  output["data_width"] = access_width
  output["hdl_path"] = hdl_path_csv
  output["capacity_list"] = capacity_csv
  output["sram_indices"] = sram_index_csv
  output["bank_indices"] = bank_index_csv
  output["target_specs"] = target_specs
  output["total_words"] = total_words
  output["total_capacity"] = total_capacity_text
  output["bank_capacity_words"] = bank_capacity_words
  output["address_interleave"] = address_interleave
  output["interleave_granularity_bytes"] = interleave_granularity_bytes
  output["interleave_granularity_words"] = interleave_granularity_words

  if (validate)
    print "CONFIG_VALID"
  else if (requested_key != "")
    print output[requested_key]
  else {
    print "sram_count=" expected_sram_count
    print "banks_per_sram=" expected_bank_count
    print "address_interleave=" address_interleave
    print "interleave_granularity=" interleave_granularity_bytes \
          "B (" interleave_granularity_words " words)"
    if (address_interleave == 1)
      print "mapping_per_sram=chunk=address/" interleave_granularity_words \
            ",bank=chunk%" expected_bank_count \
            ",row=(chunk/" expected_bank_count ")*" \
            interleave_granularity_words "+address%" \
            interleave_granularity_words
    else
      print "mapping_per_sram=bank=address/bank_words,row=address%bank_words"
    print "total_words_all_srams=" total_words
    print "sram[0].total_capacity=" total_capacity_text
    print "sram[0].bank_capacity_words=" bank_capacity_words
    print "data_width=" access_width "bit"
    print "word_bytes=" word_bytes
    for (sram_index = 0; sram_index < expected_sram_count; sram_index++) {
      print "sram[" sram_index "].total_words=" sram_words[sram_index]
      for (bank_index = 0; bank_index < expected_bank_count; bank_index++) {
        item_number = sram_index * expected_bank_count + bank_index + 1
        if (address_interleave == 1)
          print "sram[" sram_index "].bank[" bank_index "]=" \
                resolved_path[item_number] \
                ",capacity=" resolved_capacity_text[item_number] \
                ",rows=" resolved_capacity[item_number] \
                ",first_block_word=" \
                (bank_index * interleave_granularity_words) \
                ",block_words=" interleave_granularity_words \
                ",block_stride=" \
                (expected_bank_count * interleave_granularity_words)
        else
          print "sram[" sram_index "].bank[" bank_index "]=" \
                resolved_path[item_number] \
                ",capacity=" resolved_capacity_text[item_number] \
                ",rows=" resolved_capacity[item_number] \
                ",first_word=" (bank_index * resolved_capacity[item_number]) \
                ",last_word=" \
                (((bank_index + 1) * resolved_capacity[item_number]) - 1)
      }
    }
  }
}
