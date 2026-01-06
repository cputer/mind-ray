# pbrt-v4 GPU Adapter

## Status: NOT INSTALLED

## Overview

pbrt-v4 is the reference implementation from "Physically Based Rendering" (4th edition).
It supports GPU rendering via CUDA/OptiX.

## Tier Classification

- **Tier B** (end-to-end): pbrt-v4 reports wall-clock time, not kernel-only
- Cannot be compared directly with Mind-Ray Tier A results

## Installation

```powershell
# Clone repository
git clone https://github.com/mmp/pbrt-v4.git
cd pbrt-v4

# Build with CMake (requires CUDA Toolkit, OptiX SDK)
mkdir build && cd build
cmake -DPBRT_USE_GPU=ON ..
cmake --build . --config Release

# Copy executable
copy Release\pbrt.exe ..\..\bench\engines\pbrt-v4\pbrt.exe
```

## Required Files

After installation, this folder should contain:
- `pbrt.exe` - Main executable
- `scenes/` - Test scene files (pbrt format)

## CLI Usage

```powershell
# Render a scene
.\pbrt.exe --gpu scenes/spheres.pbrt

# Expected output includes:
# Rendering: [====...====] (100.0%)
# Total time: X.XXX s
```

## Output Keys (Tier B)

pbrt-v4 does not output kernel-only timing. Parse wall-clock from stdout:
```
TOTAL_TIME_SEC=<float>   # End-to-end render time
```

## Scene Compatibility

pbrt-v4 uses its own scene format (.pbrt files).
For comparison, create equivalent scenes that match Mind-Ray's SCENE_HASH parameters:
- Resolution, SPP, bounces, geometry must match
- Mark comparisons as "approximate" unless scene parity verified

## Notes

- pbrt-v4 GPU mode uses OptiX internally
- No kernel-only timing exposed without source modification
- Suitable for Tier B (end-to-end) comparisons only
