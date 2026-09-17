BEGIN {
  error_count = 0
  declaration_count = 0
  if (string_key !~ /^[A-Z][A-Z0-9_]*$/) {
    print "ERROR: string_key must be an uppercase identifier" > "/dev/stderr"
    exit 1
  }
}

{
  line = $0
  sub(/[[:space:]]*\/\/.*/, "", line)
  pattern = "^[[:space:]]*localparam[[:space:]]+string[[:space:]]+" \
            string_key "[[:space:]]*="
  if (line ~ pattern) {
    declaration_count++
    value = line
    sub(/^[^=]*=[[:space:]]*/, "", value)
    sub(/[[:space:]]*;[[:space:]]*$/, "", value)
    if (value !~ /^"[^"]+"$/) {
      print "ERROR: " string_key " must be one non-empty quoted string" \
            > "/dev/stderr"
      error_count++
    }
    else {
      sub(/^"/, "", value)
      sub(/"$/, "", value)
      selected_value = value
    }
  }
}

END {
  if (declaration_count != 1) {
    print "ERROR: " string_key " must be declared exactly once" > "/dev/stderr"
    error_count++
  }
  if (error_count != 0)
    exit 1
  print selected_value
}
