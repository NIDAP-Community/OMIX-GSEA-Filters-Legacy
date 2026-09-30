#!/usr/bin/env python3
"""Audit the Code Ocean adapter against the canonical public contract."""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

CONTRACT = [
    {"name": "input", "r_type": "character", "panel_type": "file", "value_type": "string", "default": None},
    {"name": "p_value_filter", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "adjusted p-value", "choices": ["adjusted p-value", "raw p-value"]},
    {"name": "p_value_threshold", "r_type": "double", "panel_type": "text", "value_type": "number", "default": 0.05},
    {"name": "enrichment_score_filter", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "NES (Normalized Enrichment Score)", "choices": ["NES (Normalized Enrichment Score)", "ES (Enrichment Score)"]},
    {"name": "enrichment_score_threshold", "r_type": "double", "panel_type": "text", "value_type": "number", "default": 0},
    {"name": "enrichment_score_sign", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "+/-", "choices": ["+/-", "+", "-"]},
    {"name": "size_filter", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "Pathway size", "choices": ["Pathway size", "Leading Edge (LE) size"]},
    {"name": "size_cutoff", "r_type": "integer", "panel_type": "text", "value_type": "number", "default": 0},
    {"name": "top_rank_filter", "r_type": "character", "panel_type": "text", "value_type": "string", "default": "all"},
    {"name": "collections_to_include", "r_type": "character", "panel_type": "text", "value_type": "string", "default": None},
    {"name": "pathways_to_include", "r_type": "character", "panel_type": "text", "value_type": "string", "default": None},
    {"name": "gene_filter_universe", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "Leading Edge (LE)", "choices": ["Leading Edge (LE)", "Pathway"]},
    {"name": "genes_to_include", "r_type": "character", "panel_type": "text", "value_type": "string", "default": None},
    {"name": "contrast_filter", "r_type": "character", "panel_type": "list", "value_type": "string", "default": "none", "choices": ["none", "keep", "remove"]},
    {"name": "contrasts", "r_type": "character", "panel_type": "text", "value_type": "string", "default": None},
]


def comparable(value):
    if value is None or value == "":
        return None
    if isinstance(value, (int, float)):
        return float(value)
    text = str(value).strip()
    if re.fullmatch(r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)", text):
        return float(text)
    return text


def parse_r_options(text: str) -> list[dict]:
    pattern = re.compile(
        r'make_option\("--(?P<name>[A-Za-z0-9_]+)"\s*,\s*'
        r'type\s*=\s*"(?P<type>[A-Za-z]+)"\s*,\s*'
        r'default\s*=\s*(?P<default>NULL|[-+]?\d+(?:\.\d+)?|"[^"]*")',
        re.DOTALL,
    )
    values = []
    for match in pattern.finditer(text):
        raw = match.group("default")
        if raw == "NULL":
            default = None
        elif raw.startswith('"'):
            default = raw[1:-1]
        else:
            default = float(raw)
        values.append({"name": match.group("name"), "type": match.group("type"), "default": default})
    return values


def parse_run_names(text: str) -> list[str]:
    match = re.search(r"param_names=\((.*?)\)", text, re.DOTALL)
    if not match:
        return []
    return re.findall(r'"([A-Za-z0-9_]+)"', match.group(1))


def audit(panel: dict, main_text: str, run_text: str, source_text: str) -> list[str]:
    findings = []
    expected_names = [item["name"] for item in CONTRACT]
    parameters = panel.get("parameters", [])
    panel_names = [item.get("param_name") for item in parameters]

    if panel.get("named_parameters") is not True:
        findings.append("named_parameters must be true")
    if len(panel_names) != len(set(panel_names)):
        findings.append("duplicate App Panel param_name values")
    missing = [name for name in expected_names if name not in panel_names]
    extra = [name for name in panel_names if name not in expected_names]
    if missing:
        findings.append("missing App Panel controls: " + ", ".join(missing))
    if extra:
        findings.append("extra App Panel controls: " + ", ".join(map(str, extra)))
    if panel_names != expected_names:
        findings.append("App Panel control order differs from the canonical schema")

    panel_by_name = {item.get("param_name"): item for item in parameters}
    for expected in CONTRACT:
        observed = panel_by_name.get(expected["name"])
        if observed is None:
            continue
        if observed.get("type") != expected["panel_type"]:
            findings.append(f"{expected['name']}: App Panel type mismatch")
        if observed.get("value_type") != expected["value_type"]:
            findings.append(f"{expected['name']}: App Panel value_type mismatch")
        if comparable(observed.get("default_value")) != comparable(expected["default"]):
            findings.append(f"{expected['name']}: App Panel default mismatch")
        if observed.get("extra_data", []) != expected.get("choices", []):
            findings.append(f"{expected['name']}: App Panel choices mismatch")

    options = parse_r_options(main_text)
    option_names = [item["name"] for item in options]
    if option_names != expected_names:
        findings.append("adapter CLI controls are missing, extra, or out of canonical order")
    option_by_name = {item["name"]: item for item in options}
    for expected in CONTRACT:
        observed = option_by_name.get(expected["name"])
        if observed is None:
            continue
        if observed["type"] != expected["r_type"]:
            findings.append(f"{expected['name']}: adapter CLI type mismatch")
        if comparable(observed["default"]) != comparable(expected["default"]):
            findings.append(f"{expected['name']}: adapter CLI default mismatch")

    run_names = parse_run_names(run_text)
    if run_names != expected_names:
        findings.append("code/run positional bindings do not match canonical order")

    scientific_path = ROOT / "code" / "functions" / "filter_gsea_function.R"
    digest = hashlib.sha256(scientific_path.read_bytes()).hexdigest()
    if digest not in source_text:
        findings.append("managed scientific source SHA-256 is absent from OMIX_MODULE_SOURCE.md")
    if "eee4433cd74d0ce9bd1daba1571ca6312cba7ea2" not in source_text:
        findings.append("canonical source record is not pinned to the reviewed contract commit")
    if 'source(file.path(adapter_code_root, "functions", "filter_gsea_function.R"))' not in main_text:
        findings.append("adapter does not source the managed scientific export")
    if 'source(file.path(adapter_code_root, "adapter_io.R"))' not in main_text:
        findings.append("adapter input translation is not loaded from adapter-owned code")

    return findings


def audit_repository() -> list[str]:
    panel = json.loads((ROOT / ".codeocean" / "app-panel.json").read_text())
    return audit(
        panel,
        (ROOT / "code" / "main.R").read_text(),
        (ROOT / "code" / "run").read_text(),
        (ROOT / "OMIX_MODULE_SOURCE.md").read_text(),
    )


if __name__ == "__main__":
    failures = audit_repository()
    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        raise SystemExit(1)
    print("GSEA Filters adapter contract checks passed")
