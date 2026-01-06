# Mind-Ray Benchmark Results

## Executive Summary

**GPU**: NVIDIA GeForce RTX 4070 Laptop GPU | **Config**: 640x360, 64 SPP, 4 bounces

| Tier | Comparison | Geomean Speedup |
|------|------------|-----------------|
| **BP** (Steady-State) | Mind-Ray vs Mitsuba 3 | **18.7x** |
| **BP** (Cold Start) | Mind-Ray vs Mitsuba 3 | **5.9x** |
| **B** (Process Wall Clock) | Mind-Ray vs Mitsuba 3 | **1.56x** |
| **A** (Kernel-Only) | Mind-Ray vs CUDA Ref | **11.2x** |

---

## Tier Definitions

| Tier | What It Measures | Includes | Excludes |
|------|------------------|----------|----------|
| **A** | Kernel-only timing | Kernel launch, execution, sync | I/O, process startup, allocation |
| **B** | Process wall clock | Full process (startup to exit) | Nothing |
| **BP** | Persistent mode | Cold start + steady-state | - |

**Rule**: Never compare numbers across tiers.

---

## Tier BP: Persistent Mode

**Mind-Ray vs Mitsuba 3** (both GPU-accelerated)

| Spheres | Mind-Ray Steady (ms) | Mitsuba 3 Steady (ms) | Speedup |
|---------|----------------------|-----------------------|---------|
| 64 | 4.51 | 101.93 | **22.6x** |
| 128 | 5.58 | 121.34 | **18.3x** |
| 256 | 6.44 | 171.65 | **15.8x** |

**Geomean Steady-State Speedup: 18.7x**

| Spheres | Mind-Ray Cold (ms) | Mitsuba 3 Cold (ms) | Speedup |
|---------|--------------------|--------------------|---------|
| 64 | 70.69 | 432.97 | **6.1x** |
| 128 | 73.94 | 487.40 | **5.9x** |
| 256 | 74.17 | 542.35 | **5.8x** |

**Geomean Cold Start Speedup: 5.9x**

**Source**: [`bench/results/LATEST_TIER_BP.md`](bench/results/LATEST_TIER_BP.md)

---

## Tier B: Process Wall Clock

**Mind-Ray vs Mitsuba 3** (GPU-only, includes process startup)

| Spheres | Mind-Ray (ms) | Mitsuba 3 (ms) | Speedup |
|---------|---------------|----------------|---------|
| 64 | 103.9 | 128.6 | **1.24x** |
| 128 | 98.3 | 150.7 | **1.53x** |
| 256 | 101.5 | 203.6 | **2.01x** |

**Geomean Speedup: 1.56x**

**Source**: [`bench/results/LATEST_TIER_B.md`](bench/results/LATEST_TIER_B.md)

---

## Tier A: Kernel-Only

**Mind-Ray vs CUDA Reference** (CUDA events / QPC timing)

| Spheres | Mind-Ray (M/s) | CUDA Ref (M/s) | Speedup |
|---------|----------------|----------------|---------|
| 16 | 5350 | 935 | **5.7x** |
| 32 | 4280 | 552 | **7.8x** |
| 64 | 3560 | 325 | **11.0x** |
| 128 | 2943 | 190 | **15.5x** |
| 256 | 2452 | 105 | **23.4x** |

**Geomean Speedup: 11.2x**

**Source**: Latest `bench/results/SCALING_*.md`

---

## Methodology

### Timing Methods

| Tier | Method |
|------|--------|
| A | CUDA events (`cudaEventElapsedTime`) or QPC + `cudaDeviceSynchronize` |
| B | PowerShell `Stopwatch` around entire process |
| BP | Per-frame timing within persistent process |

### Statistical Protocol

- **Runs**: 3 per configuration (median reported)
- **Warmup**: 1 run (Tier B) or 10 frames (Tier BP)
- **Cooldown**: 3 seconds between runs

### Scene Verification

- **SCENE_HASH**: FNV-1a hash verifies identical scene parameters (Tier A)
- **SCENE_MATCH=approx**: Scene parameters approximate but not hash-verified (Tier B/BP)

---

## Hardware

| Component | Value |
|-----------|-------|
| GPU | NVIDIA GeForce RTX 4070 Laptop GPU |
| Driver | 591.44 |
| CUDA | 12.8 |

---

## Reproducing Results

```powershell
# Tier A
.\bench\run_scaling_sweep.ps1 -Counts "16,32,64,128,256" -Runs 3

# Tier B
.\bench\run_tier_b.ps1 -SphereCounts "64,128,256" -MeasuredRuns 3

# Tier BP
.\bench\run_tier_bp.ps1 -SphereCounts "64,128,256" -Runs 3

# Regenerate pitch summary
python bench/tools/make_pitch_one_slide.py
```

---

## Raw Data

- **Tier A**: `bench/results/raw/scaling/`
- **Tier B**: `bench/results/raw/tier_b/`
- **Tier BP**: `bench/results/raw/tier_bp/`
- **Contract**: [`bench/contract_v2.md`](bench/contract_v2.md)

---

## Notes

- Mind-Ray uses a software BVH for O(log N) scaling
- CUDA Reference is brute-force O(N) (for comparison baseline)
- Mitsuba 3 is a general-purpose differentiable renderer
- All comparisons use identical or approximately matched scenes

---

*Last updated: 2026-01-06*
