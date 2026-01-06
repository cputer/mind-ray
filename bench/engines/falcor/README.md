# NVIDIA Falcor Adapter

## Status: NOT INSTALLED (Manual Build Required)

## Overview

Falcor is NVIDIA's real-time rendering research framework.
Supports DXR (DirectX Raytracing) and OptiX backends.

## Tier Classification

- **Tier B** (end-to-end): Reports total render time
- Kernel-only timing requires source modification

## Installation

```powershell
# Clone repository
git clone https://github.com/NVIDIAGameWorks/Falcor.git
cd Falcor

# Prerequisites
# - Visual Studio 2022
# - Windows SDK 10.0.19041.0+
# - CUDA Toolkit 12.x
# - OptiX SDK 7.x+

# Build
.\setup_vs2022.bat
# Open Falcor.sln in VS and build Release

# Output: build/bin/Release/
```

## Required Files

After build:
- `Mogwai.exe` - Main rendering application
- Various DLLs and render passes

## CLI Usage

```powershell
# Run with script
.\Mogwai.exe --script=scripts/benchmark.py --headless
```

## Output Keys (Tier B)

Custom script must output:
```
ENGINE=Falcor
ENGINE_VERSION=<version>
TIER=B
WALL_MS_TOTAL=<float>
```

## Scene Compatibility

Falcor uses its own scene format.
Create approximate-match scenes for comparison.
Mark as `SCENE_MATCH=approx`.

## Notes

- Complex build process with many dependencies
- Primarily Windows-focused
- Excellent for research but requires expertise to configure
- Mark as "manual build required" in reports
