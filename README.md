# Mind-Ray Path Tracer

A high-performance path tracer demonstrating **Mind** as an implementation language, with an optional CUDA backend for NVIDIA GPUs.

---

## Performance Summary

**GPU**: NVIDIA GeForce RTX 4070 Laptop GPU | **Config**: 640x360, 64 SPP, 4 bounces

### Tier BP: Persistent Mode (Mind-Ray vs Mitsuba 3)

| Metric | Geomean Speedup |
|--------|-----------------|
| **Steady-State** | **18.7x** |
| **Cold Start** | **5.9x** |

### Tier A: Kernel-Only (Mind-Ray vs CUDA Reference)

| Metric | Geomean Speedup |
|--------|-----------------|
| **Kernel Throughput** | **11.2x** |

See [`docs/PITCH_ONE_SLIDE.md`](docs/PITCH_ONE_SLIDE.md) for full breakdown and [`BENCHMARK.md`](BENCHMARK.md) for methodology.

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

# Regenerate pitch summary
python bench/tools/make_pitch_one_slide.py
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

See [`bench/contract_v2.md`](bench/contract_v2.md) for full tier definitions.

---

## Latest Reports

- [`docs/PITCH_ONE_SLIDE.md`](docs/PITCH_ONE_SLIDE.md) - One-slide summary (auto-generated)
- [`bench/results/LATEST_TIER_BP.md`](bench/results/LATEST_TIER_BP.md) - Tier BP results
- [`bench/results/LATEST_TIER_B.md`](bench/results/LATEST_TIER_B.md) - Tier B results
- [`bench/results/SCALING_*.md`](bench/results/) - Tier A scaling results

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
