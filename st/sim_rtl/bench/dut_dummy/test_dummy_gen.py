#!/usr/bin/env python3
import argparse
import pathlib
import tempfile
import unittest

import dummy_gen as dg


class DummyGenRegression(unittest.TestCase):
    def setUp(self):
        self.tmp_obj = tempfile.TemporaryDirectory()
        self.tmp = pathlib.Path(self.tmp_obj.name)

    def tearDown(self):
        self.tmp_obj.cleanup()

    def write(self, name, text):
        path = self.tmp / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def args(self, top, cfg, sources=None, flists=None, verbose=False, output="generated"):
        return argparse.Namespace(
            top=top,
            cfg=cfg,
            output=self.tmp / output,
            rtl_source=list(sources or []),
            rtl_flist=list(flists or []),
            verbose=verbose,
        )

    def root_top(self, port_name="data_i", expression="sig", declaration="wire [7:0] sig;"):
        return self.write(
            "top.sv",
            "module root ();\n%s\nchild u_x (.%s(%s));\nendmodule\n" % (declaration, port_name, expression),
        )

    def config(self, extra=""):
        return self.write("dut_dummy.cfg", "root root\ninactive u_x\n" + extra)

    # A1-A5: all top-derived width forms used by bach_core_top.
    def test_top_width_resolution_forms(self):
        symbols = {
            "simple": dg.Signal("wire", False, "[31:0]"),
            "symbolic": dg.Signal("logic", False, "[UID_W-1:0]"),
        }
        cases = {
            "simple": "[31:0]",
            "8'h0": "[7:0]",
            "simple[7:4]": "[3:0]",
            "{8'h0, simple[7:0]}": "[15:0]",
            "symbolic": "[UID_W-1:0]",
        }
        for expression, packed in cases.items():
            with self.subTest(expression=expression):
                self.assertEqual(dg.expression_signal(expression, symbols).packed, packed)

    def test_symbolic_width_parameter_relationship_is_generated(self):
        top = self.write(
            "symbolic_top.sv",
            "module root #(parameter UID_W=16) ();\nwire [UID_W-1:0] sig;\nchild u_x(.data_i(sig));\nendmodule\n",
        )
        resolved = dg.run(self.args(top, self.config()))[0]
        self.assertEqual(resolved.parameters, [("UID_W", "16")])
        dummy = (self.tmp / "generated/child_inactive_dummy.sv").read_text()
        self.assertIn("parameter UID_W = 16", dummy)
        self.assertIn("[UID_W-1:0] data_i", dummy)

    # B6-B9 and B12.
    def test_naming_basic_rules_and_unresolved(self):
        instance = dg.Instance("alpha_block", "u_alpha", [], [])
        cases = [
            ("data_i", "sig", "input"),
            ("data_o", "sig", "output"),
            ("alpha2beta_data", "sig", "output"),
            ("beta2alpha_data", "sig", "input"),
            ("plain", "sig", None),
        ]
        for port, expression, expected in cases:
            with self.subTest(port=port):
                self.assertEqual(dg.naming_direction(instance, port, expression)[0], expected)

    # B10.
    def test_suffix_and_a2b_agree(self):
        instance = dg.Instance("alpha", "u_alpha", [], [])
        direction, category, unused = dg.naming_direction(instance, "alpha2beta_data_o", "sig")
        self.assertEqual((direction, category), ("output", "both rules agreed"))

    # B11.
    def test_suffix_and_a2b_conflict(self):
        instance = dg.Instance("alpha", "u_alpha", [], [])
        direction, category, evidence = dg.naming_direction(instance, "alpha2beta_data_i", "sig")
        self.assertIsNone(direction)
        self.assertEqual(category, "naming conflict")
        self.assertEqual(set(value for unused, value in evidence), set(("input", "output")))

    # C13: unresolved direction completed manually.
    def test_manual_resolves_direction(self):
        top = self.root_top("plain", "sig")
        cfg = self.config("port u_x.plain input\n")
        resolved = dg.run(self.args(top, cfg))[0]
        self.assertEqual(resolved.status, "READY")
        self.assertEqual(resolved.ports[0].direction_source, "manual")

    # C14: empty port completed by manual direction and width.
    def test_manual_resolves_empty_connection(self):
        top = self.root_top("empty", "", "wire unused;")
        cfg = self.config("port u_x.empty output 4\n")
        resolved = dg.run(self.args(top, cfg))[0]
        self.assertEqual(resolved.ports[0].signal.packed, "[3:0]")
        self.assertEqual(resolved.status, "READY")

    # C15: matching direction is confirmation, not override.
    def test_manual_confirms_auto_direction(self):
        top = self.root_top("data_i", "sig")
        cfg = self.config("port u_x.data_i input\n")
        resolved = dg.run(self.args(top, cfg))[0]
        self.assertEqual(resolved.ports[0].direction_source, "naming")
        self.assertIn("manual direction confirmed", resolved.ports[0].notes)

    # C16.
    def test_manual_direction_conflict(self):
        top = self.root_top("data_i", "sig")
        cfg = self.config("port u_x.data_i output\n")
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, cfg))
        self.assertIn("manual direction conflict", (self.tmp / "generated/resolution_report.txt").read_text())

    # C17.
    def test_redundant_manual_width_is_error(self):
        top = self.root_top("data_i", "sig")
        cfg = self.config("port u_x.data_i input 8\n")
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, cfg))
        self.assertIn("redundant manual width", (self.tmp / "generated/resolution_report.txt").read_text())

    # C18.
    def test_manual_unknown_instance(self):
        top = self.root_top()
        cfg = self.config("port u_other.data input\n")
        with self.assertRaisesRegex(dg.Error, "unknown/non-inactive instance"):
            dg.run(self.args(top, cfg))

    # C19.
    def test_manual_unknown_port(self):
        top = self.root_top()
        cfg = self.config("port u_x.missing input\n")
        with self.assertRaisesRegex(dg.Error, "unknown port"):
            dg.run(self.args(top, cfg))

    # C20.
    def test_duplicate_manual_port(self):
        cfg = self.write(
            "dup.cfg",
            "root root\ninactive u_x\nport u_x.data_i input\nport u_x.data_i input\n",
        )
        with self.assertRaisesRegex(dg.Error, "duplicate port declaration"):
            dg.parse_cfg(cfg)

    # Existing cfg validation gates.
    def test_cfg_root_inactive_and_unknown_validation(self):
        cases = [
            ("root root\nroot root\ninactive u_x\n", "duplicate root"),
            ("inactive u_x\n", "missing root"),
            ("root root\ninactive u_x\ninactive u_x\n", "duplicate inactive"),
            ("root root\nbehavior u_x\n", "unknown directive"),
            ("root root\ninactive u_missing\n", "not found"),
        ]
        top = self.root_top()
        for index, (text, expected) in enumerate(cases):
            cfg = self.write("cfg%d.txt" % index, text)
            with self.subTest(expected=expected), self.assertRaisesRegex(dg.Error, expected):
                dg.run(self.args(top, cfg, output="out%d" % index))

    def rtl_source(self, port="data_i", direction="input", packed="[7:0]"):
        spacing = (packed + " ") if packed else ""
        return self.write("child.sv", "module child (%s wire %s%s); endmodule\n" % (direction, spacing, port))

    # D21-D23: source supplies authoritative direction/width and empty width.
    def test_rtl_declaration_authoritative_and_empty(self):
        top = self.root_top("empty", "", "wire unused;")
        cfg = self.config()
        source = self.rtl_source("empty", "output", "[3:0]")
        resolved = dg.run(self.args(top, cfg, sources=[source]))[0]
        port = resolved.ports[0]
        self.assertEqual((port.direction, port.signal.packed), ("output", "[3:0]"))
        self.assertEqual((port.direction_source, port.width_source), ("RTL", "RTL"))

    # D24.
    def test_rtl_and_naming_agree(self):
        top = self.root_top("data_i", "sig")
        source = self.rtl_source("data_i", "input", "[7:0]")
        resolved = dg.run(self.args(top, self.config(), sources=[source]))[0]
        self.assertEqual(resolved.status, "READY")
        self.assertIn("RTL/naming agreed", resolved.ports[0].notes)

    # D25.
    def test_rtl_and_naming_conflict(self):
        top = self.root_top("data_i", "sig")
        source = self.rtl_source("data_i", "output", "[7:0]")
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, self.config(), sources=[source]))
        self.assertIn("Naming Convention Conflict", (self.tmp / "generated/resolution_report.txt").read_text())

    # D26: no source argument falls back to inference.
    def test_source_unavailable_falls_back_to_top(self):
        top = self.root_top("data_i", "sig")
        resolved = dg.run(self.args(top, self.config()))[0]
        self.assertEqual(resolved.interface_source, "top inference")

    # D27.
    def test_no_source_inference_manual_chain(self):
        top = self.root_top("plain", "sig")
        resolved = dg.run(self.args(top, self.config("port u_x.plain input\n")))[0]
        self.assertEqual(resolved.interface_source, "top inference + manual")
        self.assertEqual(resolved.status, "READY")

    # Level-1/manual rule: any manual declaration is redundant when RTL exists.
    def test_manual_rejected_for_rtl_resolved_port(self):
        top = self.root_top("data_i", "sig")
        source = self.rtl_source("data_i", "input", "[7:0]")
        cfg = self.config("port u_x.data_i input\n")
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, cfg, sources=[source]))
        self.assertIn("redundant manual definition", (self.tmp / "generated/resolution_report.txt").read_text())

    # Minimal nested -f and +incdir+ discovery.
    def test_nested_flist_discovers_source(self):
        top = self.root_top("data_i", "sig")
        source = self.rtl_source("data_i", "input", "[7:0]")
        nested = self.write("nested.f", "+incdir+./include\n%s\n" % source.name)
        outer = self.write("outer.f", "-f %s\n" % nested.name)
        resolved = dg.run(self.args(top, self.config(), flists=[outer]))[0]
        self.assertEqual(resolved.interface_source, "RTL declaration")

    def test_unsupported_flist_token_fails(self):
        top = self.root_top()
        flist = self.write("bad.f", "+define+FOO\n")
        with self.assertRaisesRegex(dg.Error, "unsupported flist token"):
            dg.run(self.args(top, self.config(), flists=[flist]))

    # E28-E31.
    def test_default_and_verbose_reports(self):
        top = self.root_top("data_i", "sig")
        resolved = dg.run(self.args(top, self.config()))[0]
        default = (self.tmp / "generated/resolution_report.txt").read_text()
        self.assertIn("Status: READY", default)
        self.assertNotIn("Verbose ports:", default)
        self.assertNotIn("connection=sig", default)
        resolved = dg.run(self.args(top, self.config(), verbose=True, output="verbose"))[0]
        verbose = (self.tmp / "verbose/resolution_report.txt").read_text()
        self.assertIn("Verbose ports:", verbose)
        self.assertIn("connection=sig", verbose)

    def test_blocked_report_expands_only_problem(self):
        top = self.write(
            "mixed.sv",
            "module root ();\nwire [7:0] a,b;\nchild u_x(.data_i(a),.plain(b));\nendmodule\n",
        )
        cfg = self.config()
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, cfg))
        report = (self.tmp / "generated/resolution_report.txt").read_text()
        self.assertIn("Status: BLOCKED", report)
        self.assertIn("  plain\n", report)
        self.assertNotIn("  data_i\n", report)
        self.assertIn("Dummy Setup: BLOCKED", report)

    def selection_top(self):
        return self.write(
            "selection_top.sv",
            "module root ();\nwire [7:0] a,b;\nchild_a u_a(.data_i(a));\nchild_b u_b(.data_i(b));\nendmodule\n",
        )

    def selection_cfg(self, text):
        return self.write("selection.cfg", "root root\n" + text)

    def test_inactive_all_and_real_all(self):
        top = self.selection_top()
        inactive = dg.run(self.args(top, self.selection_cfg("inactive_all\n"), output="inactive_all"))
        self.assertEqual([item.path for item in inactive], ["u_a", "u_b"])
        real = dg.run(self.args(top, self.selection_cfg("real_all\n"), output="real_all"))
        self.assertEqual(real, [])
        report = (self.tmp / "real_all/resolution_report.txt").read_text()
        self.assertIn("Inactive instances     : 0", report)
        self.assertNotIn("Instance: u_a", report)

    def test_selection_policy_exceptions(self):
        top = self.selection_top()
        resolved = dg.run(self.args(top, self.selection_cfg("inactive_all\nreal u_a\n"), output="except_real"))
        self.assertEqual([item.path for item in resolved], ["u_b"])
        resolved = dg.run(self.args(top, self.selection_cfg("real_all\ninactive u_b\n"), output="except_inactive"))
        self.assertEqual([item.path for item in resolved], ["u_b"])

    def test_selection_validation_errors(self):
        top = self.selection_top()
        cases = [
            ("inactive_all\ninactive u_a\n", "redundant inactive selection"),
            ("real_all\nreal u_a\n", "redundant real selection"),
            ("inactive u_a\nreal u_a\n", "conflicting real/inactive"),
            ("inactive u_missing\n", "unknown instance"),
            ("inactive u_a.u_child\n", "unsupported non-direct-child selection"),
            ("inactive_all\nreal_all\n", "multiple selection policies"),
            ("real u_a\nreal u_a\n", "duplicate real"),
        ]
        for index, (text, expected) in enumerate(cases):
            with self.subTest(expected=expected), self.assertRaisesRegex(dg.Error, expected):
                dg.run(self.args(top, self.selection_cfg(text), output="invalid%d" % index))

    def test_legacy_selective_behavior_and_auto_discovery(self):
        top = self.selection_top()
        resolved = dg.run(self.args(top, self.selection_cfg("inactive u_a\n"), output="legacy"))
        self.assertEqual([item.path for item in resolved], ["u_a"])
        report = (self.tmp / "legacy/resolution_report.txt").read_text()
        self.assertIn("Selection policy: implicit real_all (legacy selective)", report)
        self.assertRegex(report, r"u_b\s+child_b\s+REAL")
        resolved = dg.run(self.args(top, self.selection_cfg("inactive_all\n"), output="discovery"))
        self.assertEqual([item.path for item in resolved], ["u_a", "u_b"])

    def test_real_unresolved_is_outside_interface_gate(self):
        top = self.write(
            "unresolved_selection.sv",
            "module root ();\nwire [7:0] a,b;\nchild_a u_a(.plain(a));\nchild_b u_b(.data_i(b));\nendmodule\n",
        )
        resolved = dg.run(self.args(top, self.selection_cfg("inactive_all\nreal u_a\n"), output="real_unresolved"))
        self.assertEqual([item.path for item in resolved], ["u_b"])
        report = (self.tmp / "real_unresolved/resolution_report.txt").read_text()
        self.assertIn("Dummy Setup: READY", report)
        self.assertNotIn("Instance: u_a", report)
        with self.assertRaisesRegex(dg.Error, "BLOCKED"):
            dg.run(self.args(top, self.selection_cfg("inactive_all\n"), output="inactive_unresolved"))

    def test_manual_targeting_real_is_error(self):
        top = self.selection_top()
        cfg = self.selection_cfg("inactive_all\nreal u_a\nport u_a.data_i input\n")
        with self.assertRaisesRegex(dg.Error, "targets REAL instance"):
            dg.run(self.args(top, cfg))

    def test_setup_report_counts_and_artifact_boundary(self):
        top = self.selection_top()
        dg.run(self.args(top, self.selection_cfg("inactive_all\nreal u_a\n"), output="artifacts"))
        output = self.tmp / "artifacts"
        report = (output / "resolution_report.txt").read_text()
        self.assertIn("Direct child instances : 2", report)
        self.assertIn("Inactive instances     : 1", report)
        self.assertIn("Real instances         : 1", report)
        self.assertIn("READY Dummy     : 1", report)
        self.assertIn("BLOCKED Dummy   : 0", report)
        self.assertRegex(report, r"u_a\s+child_a\s+REAL")
        self.assertRegex(report, r"u_b\s+child_b\s+INACTIVE")
        self.assertEqual(
            sorted(path.name for path in output.iterdir()),
            ["child_b_inactive_dummy.sv", "dummy_sources.f", "inactive_dummy_config.v", "resolution_report.txt"],
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
