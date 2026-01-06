# Mind-Ray Performance Summary (One-Slide Pitch)

**Auto-generated**: 2026-01-06 00:09:09
**Source Reports**: All numbers derived from raw benchmark logs.

---

## Hardware & Configuration

| Parameter | Value |
|-----------|-------|
| GPU | NVIDIA GeForce RTX 4070 Laptop GPU |
| Resolution | 640x360 |
| SPP | 64 |
| Bounces | 4 |
| Scene | stress (sphere grid) |
| Sphere Counts | 64, 128, 256 |

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
| Kernel Throughput | **11.2x** |

**Per-configuration:**
| Spheres | Mind-Ray (M/s) | CUDA Ref (M/s) | Speedup |
|---------|----------------|----------------|---------|
| 16 | 5350 | 935 | 5.7x |
| 32 | 4280 | 552 | 7.8x |
| 64 | 3560 | 325 | 11.0x |
| 128 | 2943 | 190 | 15.5x |
| 256 | 2452 | 105 | 23.4x |

**Source**: Latest `bench/results/SCALING_*.md`

---

## Tier Definitions

| Tier | Measures | Engines |
|------|----------|---------|
| **A** | Kernel-only (CUDA events) | Mind-Ray vs CUDA Ref |
| **B** | Process wall clock | Mind-Ray vs Mitsuba 3 (GPU) |
| **BP** | Persistent mode (cold + steady) | Mind-Ray vs Mitsuba 3 (GPU) |

**Important**: Do NOT compare numbers across tiers.

---

## Reproducibility

```powershell
# Regenerate all benchmarks
.\bench\run_scaling_sweep.ps1 -Counts "64,128,256" -Runs 3
.\bench\run_tier_b.ps1 -SphereCounts "64,128,256" -MeasuredRuns 3
.\bench\run_tier_bp.ps1 -SphereCounts "64,128,256" -Runs 3

# Regenerate this pitch file
python bench/tools/make_pitch_one_slide.py
```

---

*This file is auto-generated. Do not edit manually.*
