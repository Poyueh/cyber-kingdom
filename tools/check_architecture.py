"""Small dependency guard; no third-party tools required."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parent.parent
errors = []
for layer, allowed in {"domain": {"domain"}, "application": {"domain", "application"}}.items():
    for path in sorted((root / layer).rglob("*.gd")):
        source = re.sub(r"(?m)^\s*#.*$", "", path.read_text())
        for dependency in re.findall(r'res://([^/"\\]+)/', source):
            if dependency not in allowed:
                errors.append(f"{path.relative_to(root)}: outward dependency on {dependency}")
        for forbidden in ("Node", "Node2D", "CharacterBody2D", "Input", "FileAccess", "DirAccess", "SceneTree", "get_tree", "get_node"):
            if re.search(r"\b" + forbidden + r"\b", source):
                errors.append(f"{path.relative_to(root)}: engine boundary symbol {forbidden}")
if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("PASS: domain/application dependency boundaries")
