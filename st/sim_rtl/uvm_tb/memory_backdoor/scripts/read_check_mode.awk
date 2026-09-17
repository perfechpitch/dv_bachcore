BEGIN {
  error_count = 0
  declaration_count = 0
  if (mode_key !~ /^[A-Z][A-Z0-9_]*$/) {
    print "ERROR: mode_key must be an uppercase identifier" > "/dev/stderr"
    exit 1
  }
}

{
  line = $0
  sub(/[[:space:]]*\/\/.*/, "", line)
  pattern = "^[[:space:]]*localparam[[:space:]]+memory_check_mode_e[[:space:]]+" \
            mode_key "[[:space:]]*="
  if (line ~ pattern) {
    declaration_count++
    value = line
    sub(/^[^=]*=[[:space:]]*/, "", value)
    sub(/[[:space:]]*;[[:space:]]*$/, "", value)
    if (value == "MEMORY_CHECK_REFERENCE")
      selected_mode = "reference"
    else if (value == "MEMORY_CHECK_FILE")
      selected_mode = "file"
    else {
      print "ERROR: " mode_key \
            " must be MEMORY_CHECK_REFERENCE or MEMORY_CHECK_FILE" \
            > "/dev/stderr"
      error_count++
    }
  }
}

END {
  if (declaration_count != 1) {
    print "ERROR: " mode_key " must be declared exactly once" > "/dev/stderr"
    error_count++
  }
  if (error_count != 0)
    exit 1
  print selected_mode
}
