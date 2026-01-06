# Mind Ray Benchmark Suite

## Quick Start

### Run CUDA Benchmark

```powershell
# Ensure DLL is in place
cp ../native-cuda/mindray_cuda.dll .

# Run all scenes
./cuda_benchmark.exe --scene spheres --width 640 --height 360 --spp 64 --bounces 4
./cuda_benchmark.exe --scene cornell --width 640 --height 360 --spp 64 --bounces 4
./cuda_benchmark.exe --scene stress --width 640 --height 360 --spp 64 --bounces 4
```

### Run Comparative Suite

```powershell
./run_compare.ps1
```

## Directory Structure

```
bench/
├── cuda_benchmark.c       # CUDA benchmark harness source
├── cuda_benchmark.exe     # Compiled harness (gitignored)
├── mindray_cuda.dll       # CUDA backend (copied from native-cuda/)
├── run_compare.ps1        # Comparative benchmark script
├── results/               # Benchmark results
│   ├── *.md              # Formatted reports
│   ├── raw/              # Raw console output
│   └── *.txt             # System info captures
├── raw/                   # Raw logs from run_compare.ps1
│   ├── mindray/
│   ├── cuda_reference/
│   └── taichi/
└── competitors/           # External benchmark scripts
```

## Reproducibility Requirements

To reproduce benchmark results:

1. **Same hardware** - Results are GPU-specific
2. **Same resolution** - Default: 640x360
3. **Same SPP** - Default: 64 samples per pixel
4. **Same bounces** - Default: 4 max bounces
5. **Same seed** - Default: 42 (deterministic)
6. **Release build** - NVCC flags: `-O3 -use_fast_math`
7. **Power mode** - Laptop users: plug in, use "Best Performance"

## Toolchain Requirements

- **CUDA Toolkit**: 12.x
- **Visual Studio**: 2022 (for cl.exe)
- **GPU**: NVIDIA with CUDA support

## Methodology

### Timing
- Uses `QueryPerformanceCounter` (Windows high-resolution timer)
- 2 warmup frames excluded from timing
- 5 benchmark frames measured
- Includes `cudaDeviceSynchronize` after kernel

### Metrics

**Samples/sec** = (width × height × spp × frames) / time
- Measures complete pixel samples computed per second
- Each sample = full path trace (primary ray + bounces)

**Rays/sec** = (width × height × spp × bounces × frames) / time
- Upper bound on rays processed
- Actual count lower due to early termination, Russian roulette

### What's Excluded
- DLL loading time
- Buffer allocation
- PPM file writing
- System overhead

## Tier A Results (Kernel-Only)

See [`results/LATEST.md`](results/LATEST.md) for full Tier A results.

**Mind-Ray vs OptiX SDK**: **4.06x** geomean speedup
**Mind-Ray vs CUDA Reference**: **10.66x** geomean speedup

*Tier A excludes: Process startup, BVH build, buffer allocation, file I/O*

---

## Tier B Benchmarks (End-to-End)

See [`results/LATEST_TIER_B.md`](results/LATEST_TIER_B.md) for full Tier B results.

**GPU-Only Policy**: Only GPU-accelerated renderers are included.

*Tier B includes: Process startup, scene loading, BVH construction, rendering, output*

### Run Tier B Benchmark

```powershell
./run_tier_b.ps1 -SphereCounts '64,128,256'
```

### GPU-to-GPU Summary (Mind-Ray vs Mitsuba 3)

Up to **1.45x** faster at 256 spheres. Mind-Ray's BVH scales better with scene complexity.

### Charts

Regenerate from data:
```powershell
python generate_charts.py
```

---

## Recorded Results

- [`results/LATEST.md`](results/LATEST.md) - Tier A (kernel-only)
- [`results/LATEST_TIER_B.md`](results/LATEST_TIER_B.md) - Tier B (end-to-end)
- `_system_windows.md` - System configuration

## Comparative Benchmarks

The `run_compare.ps1` script compares:
- **Mind-Ray CUDA** - This project's GPU backend
- **CUDA Reference** - Archive reference implementation
- **Taichi** - Python path tracer (if configured)

All engines use identical:
- Resolution (640x360)
- SPP (64)
- Bounces (4)
- Scenes (spheres, cornell, stress)

Results saved to `results/COMPARE_<GPU>_<DATE>.md`.

## Notes

1. **Variance**: GPU benchmarks have ~1-5% variance between runs
2. **Thermal throttling**: Extended benchmarks may show slower times
3. **Background processes**: Close other GPU-using applications
4. **Driver updates**: Document driver version in results
