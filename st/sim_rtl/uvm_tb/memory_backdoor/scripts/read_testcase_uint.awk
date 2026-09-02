BEGIN {
  error_count = 0
  declaration_count = 0
  if (uint_key !~ /^[A-Z][A-Z0-9_]*$/) {
    print "ERROR: uint_key must be an uppercase identifier" > "/dev/stderr"
    exit 1
  }
}

{
  line = $0
  sub(/[[:space:]]*\/\/.*/, "", line)
  pattern = "^[[:space:]]*localparam[[:space:]]+int[[:space:]]+unsigned[[:space:]]+" \
            uint_key "[[:space:]]*="
  if (line ~ pattern) {
    declaration_count++
    value = line
    sub(/^[^=]*=[[:space:]]*/, "", value)
    sub(/[[:space:]]*;[[:space:]]*$/, "", value)
    if ((value != "MEM_BKDR_ADDRESS_AUTO") &&
        (value !~ /^[1-9][0-9]*$/)) {
      print "ERROR: " uint_key \
            " must be a positive decimal integer or MEM_BKDR_ADDRESS_AUTO" \
            > "/dev/stderr"
      error_count++
    }
    else
      selected_value = value
  }
}

END {
  if (declaration_count != 1) {
    print "ERROR: " uint_key " must be declared exactly once" > "/dev/stderr"
    error_count++
  }
  if (error_count != 0)
    exit 1
  print selected_value
}
