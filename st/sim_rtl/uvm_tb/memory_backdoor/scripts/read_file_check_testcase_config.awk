BEGIN {
  error_count = 0
  input_file_count = 0
  golden_file_count = 0
}

function trim(value) {
  sub(/^[[:space:]]+/, "", value)
  sub(/[[:space:]]+$/, "", value)
  return value
}

function parse_string_value(line, key,    value) {
  value = line
  sub(/^[^=]*=[[:space:]]*/, "", value)
  sub(/[[:space:]]*;[[:space:]]*$/, "", value)
  value = trim(value)
  if (value !~ /^"[^"]+"$/) {
    print "ERROR: " key " must be one non-empty quoted string" > "/dev/stderr"
    error_count++
    return ""
  }
  sub(/^"/, "", value)
  sub(/"$/, "", value)
  return value
}

{
  line = $0
  sub(/[[:space:]]*\/\/.*/, "", line)
  if (line ~ /^[[:space:]]*localparam[[:space:]]+string[[:space:]]+FILE_CHECK_INPUT_FILE[[:space:]]*=/) {
    input_file_count++
    input_file = parse_string_value(line, "FILE_CHECK_INPUT_FILE")
  }
  else if (line ~ /^[[:space:]]*localparam[[:space:]]+string[[:space:]]+FILE_CHECK_GOLDEN_FILE[[:space:]]*=/) {
    golden_file_count++
    golden_file = parse_string_value(line, "FILE_CHECK_GOLDEN_FILE")
  }
}

END {
  if (input_file_count != 1) {
    print "ERROR: FILE_CHECK_INPUT_FILE must be declared exactly once" > "/dev/stderr"
    error_count++
  }
  if (golden_file_count != 1) {
    print "ERROR: FILE_CHECK_GOLDEN_FILE must be declared exactly once" > "/dev/stderr"
    error_count++
  }
  if (error_count != 0)
    exit 1

  if (requested_key == "input_file")
    print input_file
  else if (requested_key == "golden_file")
    print golden_file
  else if (requested_key != "") {
    print "ERROR: unknown requested_key '" requested_key "'" > "/dev/stderr"
    exit 1
  }
  else
    print "FILE_CHECK_TESTCASE_CONFIG_VALID input=" input_file \
          " golden=" golden_file
}
