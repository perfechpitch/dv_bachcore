#!/usr/bin/env python3
"""Independently measure full-width DATA256 AXI payload throughput from VCD.

The performance test toggles measure on falling clock edges. At a rising edge,
handshakes use the stable values BEFORE that timestamp's changes, so an NBA
update recorded beside the clock edge cannot be mistaken for a transfer.
GB/s is decimal: one byte/ns equals one GB/s. Reads assume ARSIZE=5, as checked
by the SV monitor; writes count asserted WSTRB bits, including partial strobes.

Usage: check_perf_vcd.py run.vcd --expected-json perf_result.json
       check_perf_vcd.py --self-test
Requires only the Python 3.6 standard library.
"""

import argparse
from decimal import Decimal
import io
import json
import math
import re
import sys


TOP = 'axi4_perf_top'
COUNTERS = ('cycles', 'write_bytes', 'read_bytes', 'aw_count', 'ar_count',
            'b_count', 'rlast_count', 'w_beats', 'r_beats', 'w_stalls', 'r_stalls')
FLOAT_FIELDS = ('period_ns', 'elapsed_ns', 'write_gbps', 'read_gbps', 'total_gbps')
BUS_BITS = ('awvalid', 'awready', 'arvalid', 'arready', 'wvalid', 'wready',
            'rvalid', 'rready', 'rlast', 'bvalid', 'bready', 'aresetn')


class VcdError(ValueError):
    """The waveform does not support an unambiguous performance measurement."""


def tokens(stream):
    for line in stream:
        for token in line.split():
            yield token


def directive_body(words):
    body = []
    for word in words:
        if word == '$end':
            return body
        body.append(word)
    raise VcdError('Unterminated VCD directive')


def definitions(words):
    scope, variables, scale = [], {}, None
    for word in words:
        if word == '$scope':
            body = directive_body(words)
            if len(body) != 2:
                raise VcdError('Malformed $scope')
            scope.append(body[1])
        elif word == '$upscope':
            directive_body(words)
            if not scope:
                raise VcdError('Unbalanced $upscope')
            scope.pop()
        elif word == '$var':
            body = directive_body(words)
            if len(body) < 4:
                raise VcdError('Malformed $var')
            name = '.'.join(scope + [body[3]])
            try:
                width = int(body[1])
            except ValueError:
                raise VcdError('Invalid VCD width for ' + name)
            declaration = (body[2], width)
            if name in variables and variables[name] != declaration:
                raise VcdError('Ambiguous VCD declaration for ' + name)
            variables[name] = declaration
        elif word == '$timescale':
            body = ''.join(directive_body(words))
            match = re.fullmatch(r'([0-9]+)\s*(s|ms|us|ns|ps|fs)', body)
            if not match or scale is not None:
                raise VcdError('Missing, invalid, or repeated VCD timescale')
            unit_ns = {'s': '1e9', 'ms': '1e6', 'us': '1e3',
                       'ns': '1', 'ps': '1e-3', 'fs': '1e-6'}
            scale = Decimal(match.group(1)) * Decimal(unit_ns[match.group(2)])
            if scale <= 0:
                raise VcdError('Non-positive VCD timescale')
        elif word == '$enddefinitions':
            directive_body(words)
            if scale is None:
                raise VcdError('VCD has no timescale')
            return variables, scale
        elif word.startswith('$'):
            directive_body(words)
        else:
            raise VcdError('Unexpected token in VCD definitions: ' + word)
    raise VcdError('VCD has no $enddefinitions')


class Measurement:
    def __init__(self, variables, scale, top=TOP, interface='axi_vif'):
        self.scale = scale
        self.ids, self.widths = {}, {}
        bus_path = top + '.' + interface + '.'
        names = {'aclk': top + '.aclk', 'measure': top + '.measure',
                 'wstrb': bus_path + 'wstrb'}
        names.update((name, bus_path + name) for name in BUS_BITS)
        for name, path in names.items():
            if path not in variables:
                raise VcdError('Missing VCD signal ' + path)
            code, width = variables[path]
            expected_width = 32 if name == 'wstrb' else 1
            if width != expected_width:
                raise VcdError('%s width is %d, expected %d' %
                               (path, width, expected_width))
            if code in self.widths and self.widths[code] != width:
                raise VcdError('Inconsistent alias widths for ' + path)
            self.ids[name], self.widths[code] = code, width
        self.state, self.pending = {}, {}
        self.clock_changes = []
        self.counts = dict((name, 0) for name in COUNTERS)
        self.previous_edge, self.period = None, None
        self.start, self.end = None, None

    def change(self, code, value):
        if code not in self.widths:
            return
        value = value.lower()
        width = self.widths[code]
        if not value or any(bit not in '01xz' for bit in value) or len(value) > width:
            raise VcdError('Invalid value for VCD identifier ' + code)
        # VCD permits shortened vectors; x/z extend with the leading digit.
        value = value.rjust(width, value[0] if value[0] in 'xz' else '0')
        self.pending[code] = value
        if code == self.ids['aclk']:
            self.clock_changes.append(value)

    def old(self, name):
        return self.state.get(self.ids[name])

    def bit(self, name, tick):
        value = self.old(name)
        if value not in ('0', '1'):
            raise VcdError('Unknown %s at measured rising edge #%d' % (name, tick))
        return value == '1'

    def flush(self, tick):
        old_clock = self.old('aclk')
        new_clock = self.pending.get(self.ids['aclk'], old_clock)
        previous, transitions = old_clock, 0
        for value in self.clock_changes:
            if previous != value:
                transitions += 1
            previous = value
        if transitions > 1:
            raise VcdError('Multiple clock transitions at timestamp #%d' % tick)
        if new_clock not in (None, '0', '1'):
            raise VcdError('Unknown clock at timestamp #%d' % tick)
        rising = old_clock == '0' and new_clock == '1'
        falling = old_clock == '1' and new_clock == '0'
        old_measure = self.old('measure')
        new_measure = self.pending.get(self.ids['measure'], old_measure)
        if new_measure not in (None, '0', '1'):
            raise VcdError('Unknown measure at timestamp #%d' % tick)
        if old_measure != new_measure and new_measure == '1':
            if old_measure != '0' or not falling:
                raise VcdError('measure must initialize low and rise at a falling clock edge')
            if self.start is not None:
                raise VcdError('More than one measurement window')
            self.start = tick
        elif old_measure == '1' and new_measure == '0':
            if not falling:
                raise VcdError('measure must fall at a falling clock edge')
            self.end = tick
        if rising:
            if self.previous_edge is not None:
                period = tick - self.previous_edge
                if period <= 0:
                    raise VcdError('Non-positive clock period')
                if self.period is not None and period != self.period:
                    raise VcdError('Clock period changed at timestamp #%d: %d -> %d ticks' %
                                   (tick, self.period, period))
                self.period = period
            self.previous_edge = tick
            if old_measure == '1':
                self.sample(tick)
        self.state.update(self.pending)
        self.pending.clear()
        self.clock_changes = []

    def sample(self, tick):
        if not self.bit('aresetn', tick):
            return
        bits = dict((name, self.bit(name, tick)) for name in BUS_BITS
                    if name not in ('aresetn', 'rlast'))
        self.counts['cycles'] += 1
        for channel, counter in (('aw', 'aw_count'), ('ar', 'ar_count'), ('b', 'b_count')):
            if bits[channel + 'valid'] and bits[channel + 'ready']:
                self.counts[counter] += 1
        if bits['wvalid']:
            strobe = self.old('wstrb')
            if strobe is None or any(bit not in '01' for bit in strobe):
                raise VcdError('Unknown WSTRB with WVALID at measured rising edge #%d' % tick)
            if bits['wready']:
                self.counts['write_bytes'] += strobe.count('1')
                self.counts['w_beats'] += 1
            else:
                self.counts['w_stalls'] += 1
        if bits['rvalid']:
            last = self.bit('rlast', tick)
            if bits['rready']:
                self.counts['read_bytes'] += 32
                self.counts['r_beats'] += 1
                if last:
                    self.counts['rlast_count'] += 1
            else:
                self.counts['r_stalls'] += 1

    def result(self):
        if self.start is None or self.end is None:
            raise VcdError('Exactly one complete measurement window is required')
        if self.period is None or self.period <= 0:
            raise VcdError('At least two rising edges with positive period are required')
        if self.end <= self.start or self.counts['cycles'] == 0:
            raise VcdError('Measurement window has no elapsed time or active cycles')
        elapsed = Decimal(self.end - self.start) * self.scale
        result = dict(self.counts)
        result.update(period_ns=float(Decimal(self.period) * self.scale),
                      elapsed_ns=float(elapsed),
                      write_gbps=float(Decimal(self.counts['write_bytes']) / elapsed),
                      read_gbps=float(Decimal(self.counts['read_bytes']) / elapsed),
                      total_gbps=float(Decimal(self.counts['write_bytes'] +
                                               self.counts['read_bytes']) / elapsed))
        return result


def read_vcd(stream, top=TOP, interface='axi_vif'):
    words = iter(tokens(stream))
    variables, scale = definitions(words)
    measurement = Measurement(variables, scale, top, interface)
    tick = 0
    for word in words:
        if word.startswith('#'):
            try:
                next_tick = int(word[1:])
            except ValueError:
                raise VcdError('Invalid timestamp ' + word)
            if next_tick < tick:
                raise VcdError('VCD time moved backwards')
            if next_tick != tick:
                measurement.flush(tick)
                tick = next_tick
        elif word in ('$dumpvars', '$dumpall', '$dumpon', '$dumpoff', '$end'):
            continue
        elif word.startswith('$'):
            directive_body(words)
        elif word[:1].lower() in ('b', 'r', 's'):
            try:
                code = next(words)
            except StopIteration:
                raise VcdError('Missing identifier after VCD vector value')
            if word[0].lower() == 'b':
                measurement.change(code, word[1:])
            elif code in measurement.widths:
                raise VcdError('Expected a logic value for VCD identifier ' + code)
        elif word[:1].lower() in ('0', '1', 'x', 'z') and len(word) > 1:
            measurement.change(word[1:], word[0])
        else:
            raise VcdError('Unsupported VCD value token: ' + word)
    measurement.flush(tick)
    return measurement.result()


def compare_result(actual, expected):
    if not isinstance(expected, dict):
        raise VcdError('Expected JSON must contain one PERF_RESULT object')
    for field in COUNTERS + FLOAT_FIELDS:
        if field not in expected:
            raise VcdError('Expected JSON missing PERF_RESULT field ' + field)
        value = expected[field]
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise VcdError('Non-numeric expected field ' + field)
        if field in COUNTERS:
            matches = value == actual[field]
        else:
            # SV logs commonly print six decimals. This permits rounding only.
            matches = math.isfinite(value) and math.isclose(
                value, actual[field], rel_tol=1e-9, abs_tol=1e-6)
        if not matches:
            raise VcdError('%s differs: VCD=%r, SV=%r' % (field, actual[field], value))


def self_test():
    names = ['aclk', 'measure'] + list(BUS_BITS) + ['wstrb']
    codes = dict((name, 'v%d' % index) for index, name in enumerate(names))
    header = ['$timescale 1 ps $end', '$scope module ' + TOP + ' $end']
    for name in ('aclk', 'measure'):
        header.append('$var reg 1 %s %s $end' % (codes[name], name))
    header.append('$scope interface axi_vif $end')
    # A clock alias verifies that identifier codes, not hierarchy, carry values.
    header.append('$var wire 1 %s aclk $end' % codes['aclk'])
    for name in list(BUS_BITS) + ['wstrb']:
        header.append('$var wire %d %s %s $end' %
                      (32 if name == 'wstrb' else 1, codes[name], name))
    header += ['$upscope $end', '$upscope $end', '$enddefinitions $end', '#0', '$dumpvars']
    for name in names:
        header.append(('b0 ' if name == 'wstrb' else '0') + codes[name])
    header.append('$end')

    def event(tick, **values):
        lines = ['#%d' % tick]
        for name, value in sorted(values.items()):
            lines.append(('b%s ' % value if name == 'wstrb' else str(value)) + codes[name])
        return '\n'.join(lines)

    waveform = '\n'.join(header) + '\n' + '\n'.join([
        event(500, aclk=1),
        event(1000, aclk=0, measure=1, aresetn=1, awvalid=1, awready=1,
              arvalid=1, arready=1, wvalid=1, wready=1, wstrb='1' * 32,
              rvalid=1, rready=1, rlast=0, bvalid=0, bready=1),
        # These NBA-like posedge changes belong to the NEXT handshake.
        event(1500, aclk=1, wready=0, wstrb='1' * 16, rready=0,
              awvalid=0, arvalid=0),
        event(2000, aclk=0),
        event(2500, aclk=1, wready=1, rready=1, rlast=1, bvalid=1),
        event(3000, aclk=0),
        event(3500, aclk=1, wvalid=0, rvalid=0, bvalid=0),
        event(4000, aclk=0, measure=0),
    ])
    expected = dict(cycles=3, write_bytes=48, read_bytes=64, aw_count=1,
                    ar_count=1, b_count=1, rlast_count=1, w_beats=2, r_beats=2,
                    w_stalls=1, r_stalls=1, period_ns=1.0, elapsed_ns=3.0,
                    write_gbps=16.0, read_gbps=64.0 / 3, total_gbps=112.0 / 3)
    compare_result(read_vcd(io.StringIO(waveform)), expected)
    renamed = waveform.replace(TOP, 'monitor_unit_top').replace('axi_vif', 'bus')
    compare_result(read_vcd(io.StringIO(renamed), 'monitor_unit_top', 'bus'), expected)
    rejected = {
        'unknown handshake': waveform.replace('1' + codes['wready'] + '\n',
                                              'x' + codes['wready'] + '\n', 1),
        'unknown strobe': waveform.replace('b' + '1' * 32, 'bx' + '1' * 31, 1),
        'no window': waveform.replace('1' + codes['measure'] + '\n',
                                     '0' + codes['measure'] + '\n', 1),
        'open window': waveform.rsplit('0' + codes['measure'], 1)[0],
        'multiple windows': waveform + '\n' + event(4500, aclk=1) + '\n' +
                            event(5000, aclk=0, measure=1),
        'non-positive timescale': waveform.replace('1 ps', '0 ps'),
        'changed clock period': waveform.replace('#3500', '#3501'),
        'posedge enable': waveform.replace('#1000', '#500'),
    }
    for label, invalid in rejected.items():
        try:
            read_vcd(io.StringIO(invalid))
        except VcdError:
            continue
        raise AssertionError('Self-test did not reject ' + label)
    wrong = dict(expected, write_bytes=49)
    try:
        compare_result(expected, wrong)
    except VcdError:
        pass
    else:
        raise AssertionError('Self-test did not reject counter mismatch')
    return {'self_test': 'PASS', 'valid_cases': 2, 'rejected_cases': len(rejected) + 1,
            'verified': ['posedge pre-update sampling', '32-bit and half WSTRB',
                         'stalled beats excluded', 'request versus payload counts',
                         'timescale and alias handling', 'SV comparison']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('vcd', nargs='?', help='VCD from axi4_perf_top')
    parser.add_argument('--expected-json', help='SV PERF_RESULT as a JSON object')
    parser.add_argument('--out', help='Also write the resulting JSON to this path')
    parser.add_argument('--top', default=TOP, help='Top scope (default: %(default)s)')
    parser.add_argument('--interface', default='axi_vif',
                        help='Interface scope below top (default: %(default)s)')
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    try:
        if args.self_test:
            if args.vcd or args.expected_json:
                parser.error('--self-test cannot be combined with input files')
            result = self_test()
        else:
            if not args.vcd:
                parser.error('a VCD path or --self-test is required')
            with open(args.vcd) as stream:
                result = read_vcd(stream, args.top, args.interface)
            if args.expected_json:
                with open(args.expected_json) as stream:
                    compare_result(result, json.load(stream))
        output = json.dumps(result, indent=2, sort_keys=True) + '\n'
        if args.out:
            with open(args.out, 'w') as stream:
                stream.write(output)
        sys.stdout.write(output)
    except (VcdError, OSError, json.JSONDecodeError) as error:
        sys.stderr.write('PERF_VCD_FAIL: %s\n' % error)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
