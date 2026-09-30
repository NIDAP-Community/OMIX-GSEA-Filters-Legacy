#!/usr/bin/env python3

import copy
import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "adapter_contract", ROOT / "tests" / "check_adapter_contract.py"
)
CONTRACT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CONTRACT)


class AdapterContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.panel = json.loads((ROOT / ".codeocean" / "app-panel.json").read_text())
        cls.main_text = (ROOT / "code" / "main.R").read_text()
        cls.run_text = (ROOT / "code" / "run").read_text()
        cls.source_text = (ROOT / "OMIX_MODULE_SOURCE.md").read_text()

    def audit(self, panel=None, main_text=None):
        return CONTRACT.audit(
            panel if panel is not None else self.panel,
            main_text if main_text is not None else self.main_text,
            self.run_text,
            self.source_text,
        )

    def test_repository_contract_passes(self):
        self.assertEqual(self.audit(), [])

    def test_missing_control_is_detected(self):
        panel = copy.deepcopy(self.panel)
        panel["parameters"] = panel["parameters"][:-1]
        self.assertTrue(any("missing App Panel controls" in item for item in self.audit(panel)))

    def test_extra_control_is_detected(self):
        panel = copy.deepcopy(self.panel)
        panel["parameters"].append({
            "id": "test-extra",
            "param_name": "not_canonical",
            "type": "text",
            "value_type": "string",
        })
        self.assertTrue(any("extra App Panel controls" in item for item in self.audit(panel)))

    def test_misbound_control_is_detected(self):
        panel = copy.deepcopy(self.panel)
        panel["parameters"][1]["param_name"] = "pvalue_filter"
        findings = self.audit(panel)
        self.assertTrue(any("missing App Panel controls" in item for item in findings))
        self.assertTrue(any("extra App Panel controls" in item for item in findings))


if __name__ == "__main__":
    unittest.main()
