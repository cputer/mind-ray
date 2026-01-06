# Mind-Ray Path Tracer

A high-performance path tracer demonstrating **Mind** as an implementation language, with an optional CUDA backend for NVIDIA GPUs.

---

## Performance Summary

<!-- AUTO_BENCH_SUMMARY_START -->
**GPU**: NVIDIA GeForce RTX 4070 Laptop GPU | **Config**: 640x360, 64 SPP, 4 bounces

### Tier BP: Persistent Mode (Mind-Ray vs Mitsuba 3)

| Metric | Geomean Speedup |
|--------|-----------------|
| **Steady-State** | **18.7x** |
| **Cold Start** | **5.9x** |

### Tier A: Kernel-Only (Mind-Ray vs CUDA Reference)

| Metric | Geomean Speedup |
|--------|-----------------|
| **Kernel Throughput** | **10.7x** |

See [`docs/PITCH_ONE_SLIDE.md`](docs/PITCH_ONE_SLIDE.md) for full breakdown and [`BENCHMARK.md`](BENCHMARK.md) for methodology.
<!-- AUTO_BENCH_SUMMARY_END -->

---

## Quick Start

### Build & Run (CUDA)

```powershell
# Build BVH-accelerated kernel
.\native-cuda\build_opt.ps1

# Run benchmark
.\bench\cuda_benchmark.exe --scene stress --spheres 64 --width 640 --height 360 --spp 64
```

### Run Benchmarks

```powershell
# Tier A: Kernel-only scaling
.\bench\run_scaling_sweep.ps1 -Counts "16,32,64,128,256" -Runs 3

# Tier B: Process wall clock (GPU-only)
.\bench\run_tier_b.ps1 -SphereCounts "64,128,256" -MeasuredRuns 3

# Tier BP: Persistent mode
.\bench\run_tier_bp.ps1 -SphereCounts "64,128,256" -Runs 3

# Update docs from canonical sources
python bench/tools/update_docs.py
```

---

## Repository Layout

```
mind-ray/
├── src/                  # Mind source code (CPU renderer)
├── native-cuda/          # CUDA backend (BVH-accelerated)
├── bench/                # Benchmark suite
│   ├── results/          # Raw logs and reports
│   ├── tools/            # Pitch generator
│   └── engines/          # Engine adapters
├── docs/                 # Documentation
│   └── PITCH_ONE_SLIDE.md  # Auto-generated summary
└── BENCHMARK.md          # Methodology and tier definitions
```

---

## Benchmark Tiers

| Tier | Measures | Comparison |
|------|----------|------------|
| **A** | Kernel-only (CUDA events) | Mind-Ray vs CUDA Reference |
| **B** | Process wall clock | Mind-Ray vs Mitsuba 3 (GPU) |
| **BP** | Persistent (cold + steady) | Mind-Ray vs Mitsuba 3 (GPU) |

**Rule**: Never compare numbers across tiers.

**GPU-Only Policy**: Tier B and BP comparisons include only GPU-accelerated engines.

See [`bench/contract_v2.md`](bench/contract_v2.md) for full tier definitions.

---

## Registered Engines

<!-- AUTO_ENGINE_MATRIX_START -->
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
<!-- AUTO_ENGINE_MATRIX_END -->

---

## Latest Results

| Tier | Report | Description |
|------|--------|-------------|
| **A** | [`bench/results/LATEST.md`](bench/results/LATEST.md) | Kernel-only (Mind-Ray vs CUDA Ref) |
| **BP** | [`bench/results/LATEST_TIER_BP.md`](bench/results/LATEST_TIER_BP.md) | Persistent mode (cold + steady) |
| **B** | [`bench/results/LATEST_TIER_B.md`](bench/results/LATEST_TIER_B.md) | Process wall clock (GPU-only) |

**Pitch**: [`docs/PITCH_ONE_SLIDE.md`](docs/PITCH_ONE_SLIDE.md) (auto-generated from above)

---

## Architecture

| Component | Description |
|-----------|-------------|
| **CPU Renderer** | Pure Mind implementation |
| **CUDA Backend** | BVH-accelerated kernel |
| **Benchmark Suite** | Multi-tier comparison framework |

See [`docs/architecture.md`](docs/architecture.md) for details.

---

## License

MIT - see [LICENSE](LICENSE).

---

## Acknowledgments

- *Ray Tracing in One Weekend* - Peter Shirley
- *Physically Based Rendering* - Pharr, Jakob, Humphreys
