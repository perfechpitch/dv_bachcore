function fail(message, source_name) {
  source_name = (FILENAME == "") ? "bank record" : FILENAME
  print "ERROR: " source_name ": " message > "/dev/stderr"
  failed = 1
}

function is_uint(value) {
  return value ~ /^[0-9]+$/
}

function is_positive_uint(value) {
  return value ~ /^[1-9][0-9]*$/
}

function is_record_hex(value) {
  return value ~ /^0[xX][0-9A-Fa-f]+$/
}

function record_hex_fits_width(value, digits) {
  digits = value
  sub(/^0[xX]/, "", digits)
  sub(/^0+/, "", digits)
  if (digits == "")
    digits = "0"
  return length(digits) <= (word_bytes * 2)
}

function is_source_hex(value) {
  return value ~ /^(0[xX])?[0-9A-Fa-f]+$/
}

function trim(value) {
  sub(/^[ 	]+/, "", value)
  sub(/[ 	]+$/, "", value)
  return value
}

function normalized_hex(value) {
  sub(/^0[xX]/, "", value)
  value = toupper(value)
  sub(/^0+/, "", value)
  return (value == "") ? "0" : value
}

# Convert a validated 0x-prefixed hexadecimal value without depending on
# non-standard awk functions such as strtonum().
function hex_to_number(value, char_pos, character, digit, result) {
  result = 0
  for (char_pos = 3; char_pos <= length(value); char_pos++) {
    character = toupper(substr(value, char_pos, 1))
    if (character >= "0" && character <= "9")
      digit = character + 0
    else
      digit = index("ABCDEF", character) + 9
    result = (result * 16) + digit
  }
  return result
}

BEGIN {
  required_header = \
    "SRAM_INDEX LOGICAL_WORD_ADDRESS BYTE_ADDRESS BANK ROW " \
    "INPUT_DATA EXPECTED_DATA OUTPUT_DATA RESULT"
  failed = 0
  parameters_valid = 1
  data_count = 0
  source_count = 0

  if (!is_uint(expected_count)) {
    fail("expected_count must be a non-negative decimal integer")
    parameters_valid = 0
  }
  if (!is_uint(expected_bank)) {
    fail("expected_bank must be a non-negative decimal integer")
    parameters_valid = 0
  }
  if (!is_uint(start_row)) {
    fail("start_row must be a non-negative decimal integer")
    parameters_valid = 0
  }
  if (!is_positive_uint(word_bytes)) {
    fail("word_bytes must be a positive decimal integer")
    parameters_valid = 0
  }
  if (!is_uint(sram_index)) {
    fail("sram_index must be a non-negative decimal integer")
    parameters_valid = 0
  }
  if (!is_positive_uint(bank_count)) {
    fail("bank_count must be a positive decimal integer")
    parameters_valid = 0
  }
  if (!is_positive_uint(interleave_words)) {
    fail("interleave_words must be a positive decimal integer")
    parameters_valid = 0
  }
  if ((address_interleave != "0") && (address_interleave != "1")) {
    fail("address_interleave must be 0 or 1")
    parameters_valid = 0
  }
  if (!is_positive_uint(bank_words)) {
    fail("bank_words must be a positive decimal integer")
    parameters_valid = 0
  }
  if ((allow_skip != "0") && (allow_skip != "1")) {
    fail("allow_skip must be 0 or 1")
    parameters_valid = 0
  }
  if ((expected_equals_input != "0") &&
      (expected_equals_input != "1")) {
    fail("expected_equals_input must be 0 or 1")
    parameters_valid = 0
  }

  if (parameters_valid) {
    expected_count += 0
    expected_bank += 0
    start_row += 0
    word_bytes += 0
    sram_index += 0
    bank_count += 0
    interleave_words += 0
    address_interleave += 0
    bank_words += 0
    allow_skip += 0
    expected_equals_input += 0

    if (expected_bank >= bank_count) {
      fail("expected_bank must be less than bank_count")
      parameters_valid = 0
    }
    if ((start_row + expected_count) > bank_words) {
      fail("record row range exceeds bank_words")
      parameters_valid = 0
    }
  }

  # A source file is optional. When supplied, its non-empty, non-comment
  # words must match INPUT_DATA one-for-one. Source words may omit 0x.
  if (source_file != "") {
    source_status = (getline source_line < source_file)
    if (source_status < 0) {
      fail("cannot open source_file '" source_file "'")
      close(source_file)
      parameters_valid = 0
    }
    while (source_status > 0) {
      clean_source = source_line
      sub(/[ 	]*#.*/, "", clean_source)
      sub(/[ 	]*\/\/.*/, "", clean_source)
      clean_source = trim(clean_source)
      if (clean_source != "") {
        if (!is_source_hex(clean_source))
          fail("source_file '" source_file \
               "' contains invalid data: " source_line)
        else {
          source_data[source_count] = normalized_hex(clean_source)
          source_count++
        }
      }
      source_status = (getline source_line < source_file)
    }
    close(source_file)

    if (parameters_valid && (source_count != expected_count))
      fail("source_file contains " source_count \
           " data words, expected " expected_count)
  }
}

NR == 1 {
  header_seen = 1
  if ($0 != required_header)
    fail("invalid header; expected '" required_header "'")
  next
}

{
  data_count++

  if (NF != 9) {
    fail("line " FNR " must contain exactly 9 whitespace-separated fields")
    next
  }

  if (!is_uint($1))
    fail("line " FNR ": SRAM_INDEX must be an unsigned decimal integer")
  else if (parameters_valid && (($1 + 0) != sram_index))
    fail("line " FNR ": SRAM_INDEX is " $1 ", expected " sram_index)

  if (!is_uint($4))
    fail("line " FNR ": BANK must be an unsigned decimal integer")
  else if (parameters_valid && (($4 + 0) != expected_bank))
    fail("line " FNR ": BANK is " $4 ", expected " expected_bank)

  if (!is_uint($5)) {
    fail("line " FNR ": ROW must be an unsigned decimal integer")
    row_valid = 0
  }
  else {
    row_valid = 1
    actual_row = $5 + 0
    if (parameters_valid) {
      expected_row = start_row + data_count - 1
      if (actual_row != expected_row)
        fail("line " FNR ": ROW is " actual_row ", expected " expected_row)
      if (actual_row >= bank_words)
        fail("line " FNR ": ROW is outside bank_words")
    }
  }

  if (!is_uint($2)) {
    fail("line " FNR \
         ": LOGICAL_WORD_ADDRESS must be an unsigned decimal integer")
    logical_valid = 0
  }
  else {
    logical_valid = 1
    actual_logical = $2 + 0
    if (parameters_valid && row_valid) {
      if (address_interleave != 0)
        expected_logical = \
          int(actual_row / interleave_words) * \
            (bank_count * interleave_words) + \
          expected_bank * interleave_words + \
          (actual_row % interleave_words)
      else
        expected_logical = expected_bank * bank_words + actual_row
      if (actual_logical != expected_logical)
        fail("line " FNR ": LOGICAL_WORD_ADDRESS is " actual_logical \
             ", expected " expected_logical)
    }
  }

  if (!is_record_hex($3))
    fail("line " FNR \
         ": BYTE_ADDRESS must be a 0x-prefixed hexadecimal value")
  else if (parameters_valid && logical_valid) {
    expected_byte_address = actual_logical * word_bytes
    actual_byte_address = hex_to_number($3)
    if (actual_byte_address != expected_byte_address)
      fail("line " FNR ": BYTE_ADDRESS is " $3 \
           ", expected logical address * word_bytes = " \
           expected_byte_address)
  }

  if (!is_record_hex($6))
    fail("line " FNR ": INPUT_DATA must be a 0x-prefixed hexadecimal value")
  else if (parameters_valid && !record_hex_fits_width($6))
    fail("line " FNR ": INPUT_DATA exceeds configured data width")
  else if ((source_file != "") && (data_count <= source_count) &&
           (normalized_hex($6) != source_data[data_count - 1]))
    fail("line " FNR ": INPUT_DATA differs from source_file word " \
         data_count)

  if (!is_record_hex($7))
    fail("line " FNR \
         ": EXPECTED_DATA must be a 0x-prefixed hexadecimal value")
  else if (parameters_valid && !record_hex_fits_width($7))
    fail("line " FNR ": EXPECTED_DATA exceeds configured data width")
  else if (expected_equals_input && is_record_hex($6) &&
           (normalized_hex($7) != normalized_hex($6)))
    fail("line " FNR ": EXPECTED_DATA differs from INPUT_DATA")

  if (allow_skip) {
    if ($8 != "NOT_CHECKED")
      fail("line " FNR ": OUTPUT_DATA must be NOT_CHECKED when skipping")
    if ($9 != "SKIP")
      fail("line " FNR ": RESULT must be SKIP when skipping")
  }
  else {
    if (!is_record_hex($8))
      fail("line " FNR \
           ": OUTPUT_DATA must be a 0x-prefixed hexadecimal value")
    else if (parameters_valid && !record_hex_fits_width($8))
      fail("line " FNR ": OUTPUT_DATA exceeds configured data width")
    else if (is_record_hex($7) &&
             (normalized_hex($8) != normalized_hex($7)))
      fail("line " FNR ": OUTPUT_DATA differs from EXPECTED_DATA")
    if ($9 != "PASS")
      fail("line " FNR ": RESULT must be PASS")
  }
}

END {
  if (!header_seen)
    fail("record is empty or missing its header")
  if (parameters_valid && (data_count != expected_count))
    fail("record contains " data_count " data rows, expected " \
         expected_count)

  if (failed)
    exit 1

  print "BANK_RECORD_VALID file=" FILENAME \
        " sram=" sram_index " bank=" expected_bank \
        " rows=" data_count " allow_skip=" allow_skip
}
