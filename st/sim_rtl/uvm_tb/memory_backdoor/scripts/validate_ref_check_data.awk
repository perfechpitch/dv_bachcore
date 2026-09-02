function fail(message, source_name) {
  source_name = (FILENAME == "") ? "ref_check data" : FILENAME
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

function trim(value) {
  sub(/^[ \t]+/, "", value)
  sub(/[ \t]+$/, "", value)
  return value
}

function validate_source_file(    status, line, line_number, clean,
                                  field_count, fields, address, data) {
  if (source_file == "")
    return

  status = (getline line < source_file)
  if (status < 0) {
    fail("cannot open source_file '" source_file "'")
    close(source_file)
    return
  }
  if (status == 0) {
    fail("source_file '" source_file "' is empty")
    close(source_file)
    return
  }

  line_number = 1
  if (line != required_header)
    fail("source_file '" source_file "' has invalid header; expected '" \
         required_header "'")

  while ((status = (getline line < source_file)) > 0) {
    line_number++
    clean = trim(line)
    field_count = split(clean, fields, /[ \t]+/)
    if (clean == "" || field_count != 2) {
      fail("source_file '" source_file "' line " line_number \
           " must contain exactly 2 whitespace-separated fields")
      source_count++
      continue
    }

    address = fields[1]
    data = fields[2]
    if (!is_uint(address) || (address + 0) != source_count)
      fail("source_file '" source_file "' line " line_number \
           " has invalid logical address")

    if (!is_hex(data))
      fail("source_file '" source_file "' line " line_number \
           " has invalid hexadecimal DATA")
    else {
      if (!hex_fits_access_width(data))
        fail("source_file '" source_file "' line " line_number \
             " DATA exceeds access_width")
      source_data[source_count] = normalize_hex(data)
      source_data_valid[source_count] = 1
    }
    source_count++
  }
  if (status < 0)
    fail("error while reading source_file '" source_file "'")
  close(source_file)

  if (source_count != expected_count)
    fail("source_file '" source_file "' contains " source_count \
         " data rows; expected " expected_count)
}

BEGIN {
  required_header = "LOGICAL_WORD_ADDRESS DATA"
  error_count = 0
  data_count = 0
  source_count = 0

  if (!is_positive_uint(expected_count))
    fail("expected_count must be a positive integer")
  if (!is_positive_uint(access_width))
    fail("access_width must be a positive integer")

  if (is_positive_uint(access_width))
    max_hex_digits = int((access_width + 3) / 4)
  else
    max_hex_digits = 0

  validate_source_file()
}

NR == 1 {
  if ($0 != required_header)
    fail("invalid header; expected '" required_header "'")
  next
}

NR > 1 {
  data_count++
  if (NF != 2) {
    fail("line " FNR " must contain exactly 2 whitespace-separated fields")
    next
  }

  if (!is_uint($1) || ($1 + 0) != (data_count - 1))
    fail("line " FNR ": invalid LOGICAL_WORD_ADDRESS")

  if (!is_hex($2))
    fail("line " FNR ": invalid hexadecimal DATA")
  else if (!hex_fits_access_width($2))
    fail("line " FNR ": DATA exceeds access_width")
  else if (source_file != "" && source_data_valid[data_count - 1] &&
           normalize_hex($2) != source_data[data_count - 1])
    fail("line " FNR ": DATA differs from source_file word " data_count)
}

END {
  if (NR == 0)
    fail("empty input file")
  if (data_count != expected_count)
    fail("contains " data_count " data rows; expected " expected_count)
  if (error_count != 0)
    exit 1
  print "REF_CHECK_DATA_VALID file=" FILENAME " words=" data_count
}
