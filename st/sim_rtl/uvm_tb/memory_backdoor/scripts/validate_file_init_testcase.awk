function trim(value) {
  sub(/^[ \t]+/, "", value)
  sub(/[ \t]+$/, "", value)
  return value
}

function fail(message) {
  print "ERROR: " message > "/dev/stderr"
  failed = 1
}

function emit(message) {
  if (requested_key == "")
    print message
}

function bank_number(name, text) {
  text = name
  sub(/^FILE_INIT_SRAM0_BANK/, "", text)
  sub(/_.*/, "", text)
  return text + 0
}

function read_hex_file(file_name, bank, line, clean, digits, status, count) {
  count = 0
  status = (getline line < file_name)
  if (status < 0) {
    fail("cannot open bank " bank " data file '" file_name "'")
    close(file_name)
    return -1
  }
  while (status > 0) {
    clean = line
    sub(/[ \t]*(#|\/\/).*/, "", clean)
    clean = trim(clean)
    if (clean != "") {
      if (clean !~ /^(0[xX])?[0-9A-Fa-f]+$/)
        fail("bank " bank " file '" file_name "' has invalid data line: " line)
      else {
        digits = clean
        sub(/^0[xX]/, "", digits)
        if (length(digits) * 4 > access_width)
          fail("bank " bank " file data exceeds " access_width " bits: " line)
        count++
      }
    }
    status = (getline line < file_name)
  }
  close(file_name)
  return count
}

{
  line = trim($0)
  if (line ~ /^localparam[ \t]+bit[ \t]+FILE_INIT_COMPARE_ENABLE[ \t]*=/) {
    value = line
    sub(/^[^=]*=[ \t]*/, "", value)
    sub(/[ \t]*;.*/, "", value)
    if (value == "1'b0") compare_enable = 0
    else if (value == "1'b1") compare_enable = 1
    else fail("FILE_INIT_COMPARE_ENABLE must be 1'b0 or 1'b1")
    compare_seen++
  }
  else if (line ~ /^localparam[ \t]+string[ \t]+FILE_INIT_SRAM0_BANK[0-9]+_FILE[ \t]*=/) {
    split(line, fields, /[ \t]+/)
    name = fields[3]
    bank = bank_number(name)
    value = line
    sub(/^[^=]*=[ \t]*/, "", value)
    sub(/[ \t]*;.*/, "", value)
    gsub(/^"|"$/, "", value)
    if (bank in file_seen) fail("duplicate " name)
    file_seen[bank] = 1
    bank_file[bank] = value
  }
  else if (line ~ /^localparam[ \t]+int[ \t]+unsigned[ \t]+FILE_INIT_SRAM0_BANK[0-9]+_START_ROW[ \t]*=/) {
    split(line, fields, /[ \t]+/)
    name = fields[4]
    bank = bank_number(name)
    value = line
    sub(/^[^=]*=[ \t]*/, "", value)
    sub(/[ \t]*;.*/, "", value)
    if (value !~ /^[0-9]+$/) fail(name " must be a decimal integer")
    if (bank in row_seen) fail("duplicate " name)
    row_seen[bank] = 1
    start_row[bank] = value + 0
  }
}

END {
  capacity_count = split(capacity_list, capacities, ",")
  if (sram_count != 1 || bank_count != 4)
    fail("file_init requires one SRAM with four banks")
  if (capacity_count != 4)
    fail("capacity_list must contain four bank capacities")
  if (access_width !~ /^[1-9][0-9]*$/ || (access_width % 8) != 0)
    fail("access_width must be a positive byte-aligned bit count")
  if (compare_seen != 1)
    fail("exactly one FILE_INIT_COMPARE_ENABLE is required")

  total_words = 0
  for (bank = 0; bank < 4; bank++) {
    if (!(bank in file_seen) || !(bank in row_seen)) {
      fail("bank " bank " FILE and START_ROW definitions are required")
      continue
    }
    capacity = capacities[bank + 1] + 0
    if (start_row[bank] >= capacity) {
      fail("bank " bank " start row is outside capacity")
      continue
    }
    file_name = bank_file[bank]
    if (substr(file_name, 1, 1) != "/")
      file_name = project_dir "/" file_name
    resolved_file[bank] = file_name
    count = read_hex_file(file_name, bank)
    word_count[bank] = count
    if (count <= 0)
      fail("bank " bank " data file contains no valid words")
    else if (start_row[bank] + count > capacity)
      fail("bank " bank " file has " count " words but only " \
           (capacity - start_row[bank]) " rows fit")
    else {
      emit("FILE_INIT_BANK_DATA_CHECK_PASS bank=" bank \
           " words=" count " start_row=" start_row[bank] \
           " rows=" capacity " file=" file_name)
      total_words += count
    }
  }
  for (bank in file_seen)
    if (bank < 0 || bank >= 4) fail("unknown bank " bank)
  for (bank in row_seen)
    if (bank < 0 || bank >= 4) fail("unknown bank start row " bank)

  if (requested_key == "compare_enable") print compare_enable
  else if (requested_key == "total_words") print total_words
  else if (requested_key == "bank_word_counts") {
    print word_count[0] "," word_count[1] "," \
          word_count[2] "," word_count[3]
  }
  else if (requested_key == "bank_start_rows") {
    print start_row[0] "," start_row[1] "," start_row[2] "," start_row[3]
  }
  else if (requested_key == "bank_files") {
    print resolved_file[0] "," resolved_file[1] "," \
          resolved_file[2] "," resolved_file[3]
  }
  if (failed) exit 1
}
