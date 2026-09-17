function fail(message, source_name) {
  source_name = (FILENAME == "") ? "check compare" : FILENAME
  print "ERROR: " source_name ": " message > "/dev/stderr"
  error_count++
}

function is_uint(value) {
  return value ~ /^[0-9]+$/
}

function is_positive_uint(value) {
  return value ~ /^[0-9]+$/ && (value + 0) > 0
}

function is_hex(value) {
  return value ~ /^0[xX][0-9a-fA-F]+$/
}

function normalize_hex(value, normalized) {
  normalized = tolower(value)
  sub(/^0x/, "", normalized)
  sub(/^0+/, "", normalized)
  return (normalized == "") ? "0" : normalized
}

function hex_fits_access_width(value, digits) {
  digits = substr(value, 3)
  return length(digits) <= max_hex_digits
}

BEGIN {
  required_header = "LOGICAL_WORD_ADDRESS EXPECTED_DATA DUT_DATA RESULT"
  error_count = 0
  data_count = 0

  if (!is_positive_uint(expected_count))
    fail("expected_count must be a positive integer")
  if (!is_positive_uint(access_width))
    fail("access_width must be a positive integer")

  if (is_positive_uint(access_width))
    max_hex_digits = int((access_width + 3) / 4)
  else
    max_hex_digits = 0
}

NR == 1 {
  if ($0 != required_header)
    fail("invalid header; expected '" required_header "'")
  next
}

NR > 1 {
  data_count++
  if (NF != 4) {
    fail("line " FNR " must contain exactly 4 whitespace-separated fields")
    next
  }

  if (!is_uint($1) || ($1 + 0) != (data_count - 1))
    fail("line " FNR ": invalid LOGICAL_WORD_ADDRESS")

  if (!is_hex($2))
    fail("line " FNR ": invalid hexadecimal EXPECTED_DATA")
  else if (!hex_fits_access_width($2))
    fail("line " FNR ": EXPECTED_DATA exceeds access_width")

  if (!is_hex($3))
    fail("line " FNR ": invalid hexadecimal DUT_DATA")
  else if (!hex_fits_access_width($3))
    fail("line " FNR ": DUT_DATA exceeds access_width")

  if (is_hex($2) && is_hex($3) &&
      normalize_hex($2) != normalize_hex($3))
    fail("line " FNR ": EXPECTED_DATA and DUT_DATA differ")

  if ($4 != "PASS")
    fail("line " FNR ": RESULT is not PASS")
}

END {
  if (NR == 0)
    fail("empty input file")
  if (data_count != expected_count)
    fail("contains " data_count " data rows; expected " expected_count)
  if (error_count != 0)
    exit 1
  print "CHECK_COMPARE_VALID file=" FILENAME " words=" data_count
}
