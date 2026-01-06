# LuxCoreRender Benchmark Runner
# Outputs contract-friendly stdout for Tier B benchmarks

param(
    [string]$Scene = "stress",
    [int]$Width = 640,
    [int]$Height = 360,
    [int]$Spp = 64,
    [int]$Bounces = 4,
    [int]$Spheres = 64
)

$ErrorActionPreference = "Stop"

$LUXCORE_EXE = "$PSScriptRoot\..\..\third_party\luxcorerender\luxcoreconsole.exe"
$SCENES_DIR = "$PSScriptRoot\scenes"

# Check if LuxCore is available
if (!(Test-Path $LUXCORE_EXE)) {
    "ENGINE=LuxCoreRender"
    "STATUS=unavailable"
    "ERROR=luxcoreconsole.exe not found. Download from https://luxcorerender.org/download/ and extract to bench\third_party\luxcorerender\"
    exit 1
}

# Get version
$version = "unknown"
try {
    $versionOutput = & $LUXCORE_EXE --version 2>&1
    if ($versionOutput -match "LuxCoreRender v?(\d+\.\d+)") {
        $version = $Matches[1]
    }
} catch {
    $version = "unknown"
}

# Scene file path
$sceneFile = "$SCENES_DIR\${Scene}_n${Spheres}.cfg"

# Check if scene exists, if not create one
if (!(Test-Path $sceneFile)) {
    # Create scenes directory
    if (!(Test-Path $SCENES_DIR)) {
        New-Item -ItemType Directory -Path $SCENES_DIR -Force | Out-Null
    }

    # Generate a stress scene for LuxCore
    # LuxCore uses SDL (Scene Description Language)
    $sceneContent = @"
# Auto-generated stress scene for LuxCoreRender
# Spheres: $Spheres, Resolution: ${Width}x${Height}, SPP: $Spp, Bounces: $Bounces

scene.camera.type = perspective
scene.camera.lookat.orig = 0 3 12
scene.camera.lookat.target = 0 1 0
scene.camera.fieldofview = 50

film.width = $Width
film.height = $Height
film.outputs.0.type = RGB_IMAGEPIPELINE
film.outputs.0.filename = output.png

sampler.type = SOBOL
halt.spp = $Spp

renderengine.type = PATHCPU
path.maxdepth = $Bounces

# Sky light
scene.lights.sky.type = sky2
scene.lights.sky.gain = 1 1 1

# Ground plane material
scene.materials.ground.type = matte
scene.materials.ground.kd = 0.5 0.5 0.5

# Ground plane
scene.objects.ground.ply = ground.ply
scene.objects.ground.material = ground
"@

    # Add sphere objects
    $gridSize = [math]::Ceiling([math]::Sqrt($Spheres))
    $spacing = 2.0
    $offset = ($gridSize - 1) * $spacing / 2.0

    for ($i = 0; $i -lt $Spheres; $i++) {
        $x = ($i % $gridSize) * $spacing - $offset
        $z = [math]::Floor($i / $gridSize) * $spacing - $offset
        $y = 0.5

        $r = [math]::Abs([math]::Sin($i * 0.7)) * 0.8 + 0.2
        $g = [math]::Abs([math]::Sin($i * 1.3)) * 0.8 + 0.2
        $b = [math]::Abs([math]::Sin($i * 2.1)) * 0.8 + 0.2

        $sceneContent += @"

scene.materials.sphere$i.type = matte
scene.materials.sphere$i.kd = $r $g $b
scene.objects.sphere$i.type = sphere
scene.objects.sphere$i.radius = 0.5
scene.objects.sphere$i.transformation = 1 0 0 0  0 1 0 0  0 0 1 0  $x $y $z 1
scene.objects.sphere$i.material = sphere$i
"@
    }

    # Write scene file
    [System.IO.File]::WriteAllText($sceneFile, $sceneContent)
    Write-Host "# Generated scene: $sceneFile" -ForegroundColor Gray
}

# Output contract header
"ENGINE=LuxCoreRender"
"ENGINE_VERSION=$version"
"TIER=B"
"SCENE=$Scene"
"WIDTH=$Width"
"HEIGHT=$Height"
"SPP=$Spp"
"BOUNCES=$Bounces"
"SPHERES=$Spheres"
"SCENE_MATCH=approx"

# Run LuxCore and measure wall time
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $output = & $LUXCORE_EXE -o $sceneFile 2>&1
    $exitCode = $LASTEXITCODE
} catch {
    "ERROR=LuxCore execution failed: $_"
    exit 1
}

$stopwatch.Stop()
$wallMs = $stopwatch.Elapsed.TotalMilliseconds

# Calculate throughput
$totalSamples = $Width * $Height * $Spp
$wallSec = $wallMs / 1000.0
$samplesPerSec = $totalSamples / $wallSec / 1000000.0

# Output timing
"WALL_MS_TOTAL=$([math]::Round($wallMs, 2))"
"WALL_SAMPLES_PER_SEC=$([math]::Round($samplesPerSec, 4))"

"STATUS=complete"
