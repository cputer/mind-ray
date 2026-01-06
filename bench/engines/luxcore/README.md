# LuxCoreRender Tier B Adapter

## Status: MANUAL_REQUIRED

LuxCoreRender requires manual download and installation.

## Installation Steps

1. Download from https://luxcorerender.org/download/
2. Download `luxcorerender-{version}-win64.zip`
3. Extract to `bench\third_party\luxcorerender\`
4. Verify `luxcoreconsole.exe` exists at `bench\third_party\luxcorerender\luxcoreconsole.exe`

## Dependencies

- Microsoft Visual C++ Redistributable for Visual Studio 2017+
- Intel C++ Redistributable (for some versions)

## Tier Classification

- **Tier B** (end-to-end): Measures total wall-clock time including scene parsing, BVH build, rendering

## CLI Usage

```powershell
.\run.ps1 -Scene stress -Width 640 -Height 360 -Spp 64 -Bounces 4 -Spheres 64
```

## Output Keys (Tier B)

```
ENGINE=LuxCoreRender
ENGINE_VERSION=<version>
TIER=B
SCENE=stress
WIDTH=640
HEIGHT=360
SPP=64
BOUNCES=4
SPHERES=64
SCENE_MATCH=approx
WALL_MS_TOTAL=<ms>
WALL_SAMPLES_PER_SEC=<M>
STATUS=complete
```

## Notes

- Uses luxcoreconsole for headless rendering
- Scene generation creates LuxCore-compatible SDL format
- GPU rendering via CUDA if available
