#!/usr/bin/env python3
"""
Regenerate benchmark documentation from canonical JSON sources.

Usage:
    python update_docs.py

Sources:
    results/LATEST_TIER_B_RESULTS.json

Outputs:
    results/LATEST_TIER_B.md
    Updates bench/README.md Tier B section
"""

import json
import math
from pathlib import Path
from datetime import datetime

BENCH_DIR = Path(__file__).parent
RESULTS_DIR = BENCH_DIR / "results"


def load_tier_b_results():
    """Load Tier B results from canonical JSON."""
    json_path = RESULTS_DIR / "LATEST_TIER_B_RESULTS.json"
    with open(json_path) as f:
        return json.load(f)


def geomean(values):
    """Calculate geometric mean."""
    if not values:
        return 0
    product = 1
    for v in values:
        product *= v
    return product ** (1 / len(values))


def generate_tier_b_markdown(data):
    """Generate LATEST_TIER_B.md from JSON data."""
    lines = []
    lines.append("# Tier B Benchmark Results")
    lines.append("")
    lines.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append(f"**Source**: `results/LATEST_TIER_B_RESULTS.json`")
    lines.append("")
    lines.append("## Tier Definition")
    lines.append("")
    lines.append("**Tier B** = End-to-end wall clock time (process start to completion)")
    lines.append("")
    lines.append("Includes: Process startup, DLL/library loading, scene parsing, BVH construction, rendering, file output")
    lines.append("")
    lines.append("## Engine Status")
    lines.append("")
    lines.append("| Engine | Status | Version | Notes |")
    lines.append("|--------|--------|---------|-------|")

    for engine, info in data["engine_status"].items():
        status = info.get("status", "unknown")
        version = info.get("version", "-")
        notes = info.get("notes", info.get("reason", "-"))
        lines.append(f"| {engine} | {status} | {version} | {notes} |")

    lines.append("")
    lines.append("## Benchmark Configuration")
    lines.append("")
    config = data["benchmark_config"]
    lines.append(f"- Resolution: {config['resolution']}")
    lines.append(f"- SPP: {config['spp']}")
    lines.append(f"- Bounces: {config['bounces']}")
    lines.append(f"- Scenes: {', '.join(config['scenes'])}")
    lines.append("")

    lines.append("## Results (Wall Clock ms)")
    lines.append("")
    lines.append("| Scene | Mind-Ray | Mitsuba 3 | Cycles | LuxCore |")
    lines.append("|-------|----------|-----------|--------|---------|")

    results = data["results"]
    scenes = config["scenes"]

    for scene in scenes:
        mr = results.get("mindray", {}).get(scene, {}).get("wall_ms", "-")
        mi = results.get("mitsuba3", {}).get(scene, {}).get("wall_ms", "-")
        cy = results.get("cycles", {}).get(scene, {}).get("wall_ms", "-")
        lx = results.get("luxcore", {}).get(scene, {}).get("wall_ms_warm", "-")

        mr_str = f"{mr:.1f}" if isinstance(mr, (int, float)) else mr
        mi_str = f"{mi:.1f}" if isinstance(mi, (int, float)) else mi
        cy_str = f"{cy:.1f}" if isinstance(cy, (int, float)) else cy
        lx_str = f"{lx:.1f}" if isinstance(lx, (int, float)) else lx

        lines.append(f"| {scene} | {mr_str} | {mi_str} | {cy_str} | {lx_str} |")

    lines.append("")
    lines.append("## Speedups vs Mind-Ray")
    lines.append("")

    comp = data.get("comparisons", {}).get("vs_mindray_wall_clock", {})
    geo = comp.get("geomean", {})

    lines.append("| Engine | Geomean Slowdown |")
    lines.append("|--------|------------------|")
    lines.append(f"| Mind-Ray | 1.00x (baseline) |")
    lines.append(f"| Mitsuba 3 | {geo.get('mitsuba3_slower', '-'):.2f}x slower |")
    lines.append(f"| Cycles | {geo.get('cycles_slower', '-'):.2f}x slower |")
    lines.append(f"| LuxCore | {geo.get('luxcore_slower', '-'):.2f}x slower |")

    lines.append("")
    lines.append("## Notes")
    lines.append("")
    for note in data.get("notes", []):
        lines.append(f"- {note}")

    lines.append("")
    lines.append("## LuxCore Cold Start")
    lines.append("")
    lux_cold = results.get("luxcore", {}).get("stress_n64", {}).get("wall_ms_cold")
    if lux_cold:
        lines.append(f"First run with kernel compilation: **{lux_cold/1000:.1f} seconds**")
        lines.append("")
        lines.append("LuxCore compiles OpenCL kernels on first run. Subsequent WARM runs use cached kernels.")

    return "\n".join(lines)


def update_readme_tier_b(data):
    """Update README.md Tier B section."""
    readme_path = BENCH_DIR / "README.md"

    with open(readme_path, "r") as f:
        content = f.read()

    # Find Tier B section markers
    tier_b_start = content.find("## Tier B Benchmarks")
    if tier_b_start == -1:
        print("Warning: Tier B section not found in README.md")
        return

    # Find next section
    next_section = content.find("\n## ", tier_b_start + 10)
    if next_section == -1:
        next_section = len(content)

    # Generate new Tier B section
    results = data["results"]
    comp = data.get("comparisons", {}).get("vs_mindray_wall_clock", {})
    geo = comp.get("geomean", {})

    new_section = """## Tier B Benchmarks (End-to-End)

See [`results/LATEST_TIER_B_RESULTS.json`](results/LATEST_TIER_B_RESULTS.json) for full data.

**GPU-Only Policy**: Only GPU-accelerated renderers included.

*Tier B = Process startup + scene load + BVH build + render + output*

### Engine Status

| Engine | Status | Version |
|--------|--------|---------|
| Mind-Ray | Ready | 1.0 |
| Mitsuba 3 | Ready | 3.7.1 |
| Cycles | Ready | 5.0 |
| LuxCore | Ready | 2.8alpha1 |
| PBRT-v4 | Blocked | - |
| Falcor | Pending | - |

### Benchmark Results (Wall Clock ms)

| Scene | Mind-Ray | Mitsuba 3 | Cycles | LuxCore |
|-------|----------|-----------|--------|---------|
"""

    scenes = data["benchmark_config"]["scenes"]
    for scene in scenes:
        mr = results.get("mindray", {}).get(scene, {}).get("wall_ms", "-")
        mi = results.get("mitsuba3", {}).get(scene, {}).get("wall_ms", "-")
        cy = results.get("cycles", {}).get(scene, {}).get("wall_ms", "-")
        lx = results.get("luxcore", {}).get(scene, {}).get("wall_ms_warm", "-")

        mr_str = f"{mr:.0f}" if isinstance(mr, (int, float)) else mr
        mi_str = f"{mi:.0f}" if isinstance(mi, (int, float)) else mi
        cy_str = f"{cy:.0f}" if isinstance(cy, (int, float)) else cy
        lx_str = f"{lx:.0f}" if isinstance(lx, (int, float)) else lx

        new_section += f"| {scene} | {mr_str} | {mi_str} | {cy_str} | {lx_str} |\n"

    new_section += f"""
**Mind-Ray vs All (Geomean)**:
- vs Mitsuba 3: **{geo.get('mitsuba3_slower', 0):.1f}x faster**
- vs Cycles: **{geo.get('cycles_slower', 0):.1f}x faster**
- vs LuxCore: **{geo.get('luxcore_slower', 0):.1f}x faster**

### Run Benchmarks

```powershell
python bench/tier_b_harness.py
```

"""

    # Replace section
    new_content = content[:tier_b_start] + new_section + content[next_section:]

    with open(readme_path, "w") as f:
        f.write(new_content)

    print(f"Updated: {readme_path}")


def main():
    print("Loading Tier B results...")
    data = load_tier_b_results()

    print("Generating LATEST_TIER_B.md...")
    md_content = generate_tier_b_markdown(data)
    md_path = RESULTS_DIR / "LATEST_TIER_B.md"
    with open(md_path, "w") as f:
        f.write(md_content)
    print(f"Written: {md_path}")

    print("Updating README.md...")
    update_readme_tier_b(data)

    print("Done!")


if __name__ == "__main__":
    main()
