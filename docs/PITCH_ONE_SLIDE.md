# Mind-Ray Performance Summary (One-Slide Pitch)

**Auto-generated**: 2026-01-06 00:44:53
**Source**: `bench/engines.json` + `bench/results/LATEST*.md`

---

## Hardware & Configuration

| Parameter | Value |
|-----------|-------|
| GPU | NVIDIA GeForce RTX 4070 Laptop GPU |
| Resolution | 640x360 |
| SPP | 64 |
| Bounces | 4 |
| Scene | stress (sphere grid) |

---

## Executive Summary

### Tier BP: Persistent Mode (Mind-Ray vs Mitsuba 3)

> **After warmup, Mind-Ray renders 18.7x faster than Mitsuba 3.**
> **Including cold start, Mind-Ray is 5.9x faster.**

| Metric | Geomean Speedup |
|--------|-----------------|
| Steady-State | **18.7x** |
| Cold Start | **5.9x** |

**Per-configuration:**
| Spheres | Steady Speedup | Cold Start Speedup |
|---------|----------------|--------------------|
| 64 | 22.6x | 6.1x |
| 128 | 18.3x | 5.9x |
| 256 | 15.8x | 5.8x |

**Source**: [`bench/results/LATEST_TIER_BP.md`](../bench/results/LATEST_TIER_BP.md)

---

### Tier B: Process Wall Clock (Mind-Ray vs Mitsuba 3)

| Metric | Geomean Speedup |
|--------|-----------------|
| Process Wall Clock | **1.56x** |

**Per-configuration:**
| Spheres | Mind-Ray (ms) | Mitsuba 3 (ms) | Speedup |
|---------|---------------|----------------|---------|
| 64 | 103.9 | 128.6 | 1.24x |
| 128 | 98.3 | 150.7 | 1.53x |
| 256 | 101.5 | 203.6 | 2.01x |

**Source**: [`bench/results/LATEST_TIER_B.md`](../bench/results/LATEST_TIER_B.md)

---

### Tier A: Kernel-Only (Mind-Ray vs CUDA Reference)

| Metric | Geomean Speedup |
|--------|-----------------|
| Kernel Throughput | **10.7x** |

**Per-configuration:**
| Spheres | Mind-Ray (M/s) | CUDA Ref (M/s) | Speedup |
|---------|----------------|----------------|---------|
| 16 | 5403 | 931 | 5.8x |
| 32 | 4078 | 547 | 7.5x |
| 64 | 3321 | 319 | 10.4x |
| 128 | 2561 | 186 | 13.8x |
| 256 | 2257 | 102 | 22.1x |

**Source**: Latest `bench/results/SCALING_*.md`

---

## Registered Engines

| Engine | Tier | Status | Source |
|--------|------|--------|--------|
| Blender Cycles | B | Manual | [Link](https://www.blender.org/download/) |
| CUDA Reference | A | Available | - |
| LuxCoreRender | B | Manual | [Link](https://luxcorerender.org/download/) |
| Mind-Ray CUDA | A | Available | - |
| Mind-Ray Tier B | B | Available | - |
| Mind-Ray Tier BP | BP | Available | - |
| Mitsuba 3 | B | Available | [Link](https://github.com/mitsuba-renderer/mitsuba3) |
| Mitsuba 3 Tier BP | BP | Available | - |
| NVIDIA Falcor | B | Unavailable | [Link](https://github.com/NVIDIAGameWorks/Falcor) |
| OptiX SDK Path Tracer | A | Available | - |
| PBRT-v4 | B | Available | [Link](https://github.com/mmp/pbrt-v4) |
| Python Reference | B | Available | - |

*Source: `bench/engines.json` (v2.1)*

---

## Tier Definitions

| Tier | Measures | Comparison |
|------|----------|------------|
| **A** | Kernel-only (CUDA events) | Mind-Ray vs CUDA Ref |
| **B** | Process wall clock | Mind-Ray vs Mitsuba 3 (GPU) |
| **BP** | Persistent (cold + steady) | Mind-Ray vs Mitsuba 3 (GPU) |

**Important**: Do NOT compare numbers across tiers.

**GPU-Only Policy**: Tier B and BP comparisons include only GPU-accelerated engines.

---

## Reproducibility

```powershell
# Run benchmarks
.\bench\run_scaling_sweep.ps1 -Counts "16,32,64,128,256" -Runs 3
.\bench\run_tier_b.ps1 -SphereCounts "64,128,256" -MeasuredRuns 3
.\bench\run_tier_bp.ps1 -SphereCounts "64,128,256" -Runs 3

# Update all docs from results
python bench/tools/update_docs.py
```

---

*This file is auto-generated from `bench/engines.json` and `bench/results/LATEST*.md`. Do not edit manually.*
