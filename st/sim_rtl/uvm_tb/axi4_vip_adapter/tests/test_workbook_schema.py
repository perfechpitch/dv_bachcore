"""Audit the active workbook and preserved BASE without rewriting any sheets."""
import hashlib
import json
from pathlib import Path
import sys
import unittest
import zipfile
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
from check_base_vip_cfg import load_rows, verify_lock
from gen_dut_vip_cfg import (build_final, load_parameter_rows,
                             validate_matching_tables, workbook_sheet_path)
from vip_workbook import load_vip_cfg, parse_value
from workbook_baseline import load_baseline
from xls_table import read_workbook

WORKBOOK = ROOT / 'docs/vip/vip_cfg.xlsx'
ACTIVATION = ROOT / 'docs/workbook_master_activation_20260917.json'
MAIN = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
UNKNOWN_REQUIREMENTS = ('bandwidth_scope', 'max_burst_beats', 'max_burst_bytes')


def fingerprint(rows):
    return hashlib.sha256(json.dumps(rows, sort_keys=True, ensure_ascii=True,
                                     separators=(',', ':')).encode('utf-8')).hexdigest()


class WorkbookSchemaTests(unittest.TestCase):
    def test_active_baseline_schema_and_complete_base_are_preserved(self):
        baseline = load_baseline()
        activation = json.loads(ACTIVATION.read_text())
        audit = json.loads((ROOT / 'docs/workbook_schema_migration_20260916.json').read_text())
        self.assertEqual(hashlib.sha256(WORKBOOK.read_bytes()).hexdigest(), baseline['current_sha256'])
        self.assertEqual(activation['version'], 1)
        self.assertEqual(activation['previous_sha256'], baseline['previous_sha256'])
        self.assertEqual(activation['current_sha256'], baseline['current_sha256'])
        self.assertEqual(audit['current_sha256'], activation['previous_sha256'])
        tables = read_workbook(str(WORKBOOK))
        self.assertEqual(list(tables), ['BASE_VIP_CFG', 'DUT_BUFF_FEATURE', 'FINAL_FEATURE'])
        expected = None
        for name, (_, rows) in tables.items():
            self.assertEqual(len(rows), 70)
            identities = [(r['section'], r['key'], r['type']) for r in rows]
            self.assertEqual(len(set((section, key) for section, key, _ in identities)), 70)
            if expected is not None:
                self.assertEqual(identities, expected)
            expected = identities
        # Task 08 is historical evidence. Task 09 may change DUT/FINAL values,
        # but every BASE row must still match the reviewed additive migration.
        base_rows = tables['BASE_VIP_CFG'][1]
        base_audit = audit['sheets']['BASE_VIP_CFG']
        self.assertEqual(fingerprint(base_rows[:55]), base_audit['original_rows_sha256'])
        self.assertEqual([dict(r, excel_row=i+57) for i, r in enumerate(base_rows[55:])],
                         base_audit['added_rows'])
        base_ref = str(WORKBOOK) + '::BASE_VIP_CFG'
        verify_lock(str(ROOT / 'docs/vip/base_vip_cfg.lock.json'), 'BASE_VIP_CFG', load_rows(base_ref))

    def test_authorized_dut_values_and_final_merge_sources(self):
        activation = json.loads(ACTIVATION.read_text())
        expected_dut = activation['expected_dut_values']
        self.assertIsInstance(expected_dut, dict)
        self.assertTrue(expected_dut)
        tables = read_workbook(str(WORKBOOK))
        dut_rows = tables['DUT_BUFF_FEATURE'][1]
        identities = {r['section'] + '.' + r['key'] for r in dut_rows}
        self.assertFalse(set(expected_dut) - identities)
        for row in dut_rows:
            identity = row['section'] + '.' + row['key']
            if identity in expected_dut:
                self.assertNotEqual(row['value'], '', identity)
                actual = parse_value(row['value'], row['type'], identity)
                self.assertIs(type(actual), type(expected_dut[identity]), identity)
                self.assertEqual(actual, expected_dut[identity], identity)
            else:
                self.assertEqual(row['value'], '', identity)
        base_ref = str(WORKBOOK) + '::BASE_VIP_CFG'
        dut_ref = str(WORKBOOK) + '::DUT_BUFF_FEATURE'
        base = load_parameter_rows(base_ref, 'base', True)
        dut = load_parameter_rows(dut_ref, 'dut', False)
        validate_matching_tables(base, dut, base_ref, dut_ref)
        expected_cfg, expected_final, _ = build_final(base, dut, base_ref, dut_ref)
        self.assertEqual(tables['FINAL_FEATURE'][1], expected_final)
        self.assertEqual(load_vip_cfg(str(WORKBOOK)), expected_cfg)

    def test_unknown_requirements_and_unassigned_dut_are_physical_blanks(self):
        expected_dut = json.loads(ACTIVATION.read_text())['expected_dut_values']
        tables = read_workbook(str(WORKBOOK))
        with zipfile.ZipFile(str(WORKBOOK)) as book:
            for name in ('BASE_VIP_CFG', 'DUT_BUFF_FEATURE', 'FINAL_FEATURE'):
                sheet = ET.fromstring(book.read(workbook_sheet_path(book, name)))
                cells = {c.attrib['r']: c for c in sheet.iter(MAIN + 'c')}
                for number, row in enumerate(tables[name][1], start=2):
                    identity = row['section'] + '.' + row['key']
                    unknown = row['section'] == 'requirements' and row['key'] in UNKNOWN_REQUIREMENTS
                    inherited = name == 'DUT_BUFF_FEATURE' and identity not in expected_dut
                    absent_base_value = (name == 'BASE_VIP_CFG' and identity in
                                         ('axi.max_outstanding_total', 'requirements.outstanding_scope'))
                    if unknown or inherited or absent_base_value:
                        cell = cells.get('C' + str(number))
                        if cell is not None:
                            for child in ('v', 'is', 'f'):
                                self.assertIsNone(cell.find(MAIN + child), name + ':' + identity)
        self.assertNotIn('axi.max_burst_len', expected_dut)

    def test_false_none_zero_and_unknown_have_distinct_meanings(self):
        cfg = load_vip_cfg(str(WORKBOOK))
        expected_dut = json.loads(ACTIVATION.read_text())['expected_dut_values']
        for key in ('max_outstanding_reads', 'max_outstanding_writes', 'max_outstanding_total'):
            self.assertEqual(cfg['axi'][key], expected_dut['axi.' + key])
            self.assertEqual(cfg['axi'][key], 128)
        self.assertEqual(cfg['axi']['default_id'], 0)
        self.assertEqual(cfg['axi']['data_width'], 256)
        self.assertEqual(cfg['axi']['id_width'], 8)
        self.assertEqual(cfg['axi']['len_width'], 4)
        self.assertEqual(cfg['axi']['max_burst_len'], 1)
        self.assertEqual(cfg['requirements']['max_wrap_size'], 'no')
        self.assertEqual(cfg['requirements']['align_info'], 'none')
        self.assertIs(cfg['requirements']['barrier'], False)
        self.assertEqual(cfg['requirements']['outstanding'], 128)
        self.assertEqual(cfg['requirements']['outstanding_scope'], 'read+write')
        self.assertEqual(cfg['requirements']['bandwidth_gbps'], 24)
        for key in UNKNOWN_REQUIREMENTS:
            self.assertIsNone(cfg['requirements'][key])


if __name__ == '__main__':
    unittest.main()
