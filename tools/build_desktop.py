#!/usr/bin/env python3
"""Export a committed source tree without modifying the user's working copy."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])

def run_logged(args, path):
    with path.open("w") as log:
        result = subprocess.run(args, stdout=log, stderr=subprocess.STDOUT)
    output = path.read_text(errors="replace")
    if result.returncode or re.search(r"SCRIPT ERROR:|(?:^|\s)ERROR:", output):
        raise RuntimeError("Build failed; see " + str(path))

def prepare_tree(ref, destination):
    tree = git("rev-parse", "--verify", "--end-of-options", ref + "^{tree}").decode().strip()
    with tarfile.open(fileobj=io.BytesIO(git("archive", tree))) as archive:
        for member in archive.getmembers():
            target = (destination / member.name).resolve()
            if destination.resolve() not in target.parents or not (member.isfile() or member.isdir()):
                raise ValueError("Unsupported archive member: " + member.name)
        archive.extractall(destination)
    project = destination / "project.godot"
    original = project.read_text()
    content, count = re.subn(r'^run/main_scene=.*$', 'run/main_scene="res://scenes/frontier.tscn"', original, flags=re.M)
    if count != 1:
        raise ValueError("Expected exactly one main scene in project.godot")
    content, count = re.subn(r'^config/name=.*$', 'config/name="Cyber Kingdom Demo"', content, flags=re.M)
    if count != 1:
        raise ValueError("Expected exactly one application name")
    setting = "textures/vram_compression/import_etc2_astc"
    if re.search(r"^" + re.escape(setting) + r"=.*$", content, flags=re.M):
        content = re.sub(r"^" + re.escape(setting) + r"=.*$", setting + "=true", content, flags=re.M)
    elif "[rendering]" in content:
        content = content.replace("[rendering]", "[rendering]\n" + setting + "=true", 1)
    else:
        content += "\n[rendering]\n" + setting + "=true\n"
    project.write_text(content)
    return tree

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", default="HEAD", help="Commit or staged tree to export")
    parser.add_argument("--output", type=Path, required=True, help="New output directory (must not exist)")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "/Applications/Godot.app/Contents/MacOS/Godot"))
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    with tempfile.TemporaryDirectory(prefix="cyber-desktop-") as folder:
        stage = Path(folder)
        tree = prepare_tree(args.ref, stage)
        engine = [args.godot, "--headless", "--path", str(stage)]
        run_logged(engine + ["--editor", "--import"], output / "import.log")
        mac = output / "macOS"
        windows = output / "Windows"
        mac.mkdir()
        windows.mkdir()
        run_logged(engine + ["--export-release", "macOS Demo", str(mac / "Cyber Kingdom Demo.app")], output / "macOS-export.log")
        run_logged(engine + ["--export-release", "Windows Demo", str(windows / "Cyber Kingdom Demo.exe")], output / "Windows-export.log")
        # ditto retains the app bundle's executable bits and macOS metadata.
        run_logged(["ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", str(mac / "Cyber Kingdom Demo.app"), str(output / "Cyber-Kingdom-macOS.zip")], output / "macOS-zip.log")
        shutil.make_archive(str(output / "Cyber-Kingdom-Windows"), "zip", windows)
        checksums = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in output.glob("*.zip")}
        version = subprocess.check_output([args.godot, "--version"], text=True).strip()
        (output / "manifest.json").write_text(json.dumps({
            "source_tree": tree, "engine": version, "entry": "res://scenes/frontier.tscn",
            "configuration": "committed settings, release export, prototype content",
            "macOS_signing": "ad-hoc; not notarized", "Windows_signing": "unsigned",
            "checksums_sha256": checksums,
            "platform_playtest": "must be recorded separately; export alone is not a pass"
        }, indent=2) + "\n")
    print("Exported desktop prototype packages to", output)

if __name__ == "__main__":
    main()
