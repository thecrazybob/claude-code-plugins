#!/usr/bin/env python3
"""Generate the API operation index from the bundled official schema; --check validates it."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "references/openapi.json"
INDEX = ROOT / "references/api-operations.md"
METHODS = {"get", "post", "put", "patch", "delete", "head", "options", "trace"}


def render(raw):
    schema = json.loads(raw)
    assert schema["openapi"].startswith("3.")
    assert schema["servers"][0]["url"] == "https://forge.laravel.com/api"
    operations = [(path, method, op) for path, item in schema["paths"].items()
                  for method, op in item.items() if method in METHODS]
    ids = [op["operationId"] for _, _, op in operations]
    assert len(ids) == len(set(ids)), "Duplicate operation IDs"

    def check_refs(value):
        if isinstance(value, dict):
            if "$ref" in value:
                ref = value["$ref"]
                assert ref.startswith("#/"), f"Non-bundled reference: {ref}"
                target = schema
                for part in ref[2:].split("/"):
                    target = target[part.replace("~1", "/").replace("~0", "~")]
            for child in value.values():
                check_refs(child)
        elif isinstance(value, list):
            for child in value:
                check_refs(child)

    check_refs(schema)
    lines = ["# Forge API operation index", "",
             "Generated from [openapi.json](openapi.json). See [api.md](api.md) for authentication, lookup, and refresh instructions.", "",
             f"{len(operations)} operations across {len(schema['paths'])} paths. "
             f"Schema SHA-256: `{hashlib.sha256(raw).hexdigest()}`.", "",
             "Paths are relative to `https://forge.laravel.com/api`. "
             "Read the operation and referenced schemas before constructing a request; API operations are not CLI subcommands.", ""]
    groups = sorted({op.get("tags", ["Other"])[0] for _, _, op in operations})
    for group in groups:
        lines += [f"## {group}", "", "| Method | Path | Operation ID | Summary | Processing | Permissions |",
                  "| --- | --- | --- | --- | --- | --- |"]
        for path, method, op in sorted(operations, key=lambda row: (row[0], row[1])):
            if op.get("tags", ["Other"])[0] != group:
                continue
            cells = [method.upper(), path, op["operationId"], op.get("summary", ""),
                     op.get("x-processingMode", "unspecified"), ", ".join(op.get("x-permissions", []))]
            lines.append("| " + " | ".join(str(c).replace("|", "\\|").replace("\n", " ") for c in cells) + " |")
        lines.append("")
    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render(SCHEMA.read_bytes())
    if args.check:
        assert INDEX.read_text() == expected, "API index is stale; run this script without --check"
        print("API references resolve; every operation is indexed; checksum matches.")
    else:
        INDEX.write_text(expected)
        print(f"Wrote {INDEX}")
