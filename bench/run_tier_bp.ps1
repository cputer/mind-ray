# Mind-Ray Tier BP (Persistent) Benchmark Harness
# Runs available Tier BP engines and generates reports
# Measures: COLD_START_MS, STEADY_MS_PER_FRAME, STEADY_P95_MS
# HARD-FAIL: Exits with code 1 if no engines ran or no results captured

param(
    [string]$Scene = "stress",
    [int]$Width = 640,
    [int]$Height = 360,
    [int]$Spp = 64,
    [int]$Bounces = 4,
    [string]$SphereCounts = "64",
    [int]$Warmup = 10,
    [int]$Frames = 60,
    [int]$Runs = 3,
    [int]$CooldownSec = 5,
    [string]$Engines = ""
)

# Parse SphereCounts from comma-separated string
$SphereCountsArray = $SphereCounts -split ',' | ForEach-Object { [int]$_.Trim() }

# Validate sphere counts
if ($SphereCountsArray.Count -eq 0) {
    Write-Host "HARD-FAIL: No valid sphere counts specified" -ForegroundColor Red
    exit 1
}
foreach ($count in $SphereCountsArray) {
    if ($count -le 0) {
        Write-Host "HARD-FAIL: Invalid sphere count: $count (must be > 0)" -ForegroundColor Red
        exit 1
    }
}

$ErrorActionPreference = "Stop"
$BENCH_DIR = $PSScriptRoot
$RESULTS_DIR = "$BENCH_DIR\results\raw\tier_bp"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TIER BP (PERSISTENT) BENCHMARK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Parameters:"
Write-Host "  Scene: $Scene"
Write-Host "  Resolution: ${Width}x${Height}"
Write-Host "  SPP: $Spp"
Write-Host "  Bounces: $Bounces"
Write-Host "  Sphere counts: $($SphereCountsArray -join ', ')"
Write-Host "  Warmup frames: $Warmup"
Write-Host "  Total frames: $Frames"
Write-Host "  Measure frames: $($Frames - $Warmup)"
Write-Host "  Runs per config: $Runs"
Write-Host "  Cooldown: ${CooldownSec}s"
Write-Host ""

# Tier BP engines
$BP_ENGINES = @(
    @{
        id = "mindray_tier_bp"
        name = "Mind-Ray"
        run_script = "$BENCH_DIR\engines\mindray_tier_bp\run.ps1"
    },
    @{
        id = "mitsuba3_bp"
        name = "Mitsuba 3"
        run_script = "$BENCH_DIR\engines\mitsuba3\run_bp.ps1"
    }
)

# Create results directory
if (!(Test-Path $RESULTS_DIR)) {
    New-Item -ItemType Directory -Path $RESULTS_DIR -Force | Out-Null
}

# Check engine availability
$availableEngines = @()
foreach ($engine in $BP_ENGINES) {
    if (Test-Path $engine.run_script) {
        # Additional check for Mind-Ray
        if ($engine.id -eq "mindray_tier_bp") {
            $mindrayExe = "$BENCH_DIR\cuda_benchmark.exe"
            if (Test-Path $mindrayExe) {
                $availableEngines += $engine
                Write-Host "Detected: $($engine.name) at $mindrayExe" -ForegroundColor Green
            } else {
                Write-Host "NOT FOUND: $($engine.name) - cuda_benchmark.exe missing" -ForegroundColor Gray
            }
        }
        # Additional check for Mitsuba
        elseif ($engine.id -eq "mitsuba3_bp") {
            $mitsubaPath = "$BENCH_DIR\third_party\mitsuba3\build\Release\python\mitsuba"
            if (Test-Path $mitsubaPath) {
                $availableEngines += $engine
                Write-Host "Detected: $($engine.name) at $mitsubaPath" -ForegroundColor Green
            } else {
                Write-Host "NOT FOUND: $($engine.name) - Mitsuba build missing" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "NOT FOUND: $($engine.name) - run script missing" -ForegroundColor Gray
    }
}

# Filter by -Engines flag if specified
if ($Engines -ne "") {
    $engineFilter = $Engines -split ',' | ForEach-Object { $_.Trim() }
    $availableEngines = $availableEngines | Where-Object { $engineFilter -contains $_.id -or $engineFilter -contains $_.name }
    Write-Host "Engine filter applied: $($engineFilter -join ', ')" -ForegroundColor Yellow
}

if ($availableEngines.Count -eq 0) {
    Write-Host "HARD-FAIL: No Tier BP engines available." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Track execution
$enginesExecuted = @()
$rawLogsCreated = @()
$allResults = @()

# Run benchmarks
foreach ($spheres in $SphereCountsArray) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Sphere Count: $spheres" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    foreach ($engine in $availableEngines) {
        Write-Host ""
        Write-Host "--- $($engine.name) ---" -ForegroundColor Yellow

        $engineResultsDir = "$RESULTS_DIR\$($engine.id)"
        if (!(Test-Path $engineResultsDir)) {
            New-Item -ItemType Directory -Path $engineResultsDir -Force | Out-Null
        }

        $coldStarts = @()
        $steadyMedians = @()
        $steadyP95s = @()

        # Measured runs
        for ($i = 1; $i -le $Runs; $i++) {
            Write-Host "  Run $i/$Runs..."

            $logFile = "$engineResultsDir\${Scene}_n${spheres}_run${i}_$TIMESTAMP.txt"
            try {
                $output = & $engine.run_script -Scene $Scene -Width $Width -Height $Height -Spp $Spp -Bounces $Bounces -Spheres $spheres -Warmup $Warmup -Frames $Frames 2>&1
                $output | Out-File -FilePath $logFile -Encoding UTF8
                $rawLogsCreated += $logFile

                # Parse metrics
                $deviceName = ""
                foreach ($line in $output) {
                    if ($line -match "COLD_START_MS=([\d.]+)") {
                        $coldStarts += [double]$Matches[1]
                    }
                    if ($line -match "STEADY_MS_PER_FRAME=([\d.]+)") {
                        $steadyMedians += [double]$Matches[1]
                    }
                    if ($line -match "STEADY_P95_MS=([\d.]+)") {
                        $steadyP95s += [double]$Matches[1]
                    }
                    if ($line -match "^DEVICE_NAME=(.+)$") {
                        $deviceName = $Matches[1]
                    }
                }

                if ($coldStarts.Count -eq $i) {
                    Write-Host "    COLD_START_MS: $($coldStarts[-1])ms  STEADY: $($steadyMedians[-1])ms  P95: $($steadyP95s[-1])ms" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "  ERROR: Run failed: $_" -ForegroundColor Red
            }

            # Cooldown between runs
            if ($i -lt $Runs) {
                Start-Sleep -Seconds $CooldownSec
            }
        }

        # Calculate statistics (median of medians, etc.)
        if ($coldStarts.Count -gt 0 -and $steadyMedians.Count -gt 0) {
            $sortedCold = $coldStarts | Sort-Object
            $sortedSteady = $steadyMedians | Sort-Object
            $sortedP95 = $steadyP95s | Sort-Object

            $medianCold = $sortedCold[[math]::Floor($sortedCold.Count / 2)]
            $medianSteady = $sortedSteady[[math]::Floor($sortedSteady.Count / 2)]
            $medianP95 = $sortedP95[[math]::Floor($sortedP95.Count / 2)]

            if ($medianCold -gt 0 -and $medianSteady -gt 0) {
                $allResults += @{
                    engine_id = $engine.id
                    engine_name = $engine.name
                    spheres = $spheres
                    cold_start_ms = $medianCold
                    steady_ms = $medianSteady
                    steady_p95_ms = $medianP95
                    runs = $coldStarts.Count
                    device_name = $deviceName
                }
                $enginesExecuted += $engine.id
                Write-Host "  Result: COLD=$([math]::Round($medianCold, 2))ms STEADY=$([math]::Round($medianSteady, 2))ms P95=$([math]::Round($medianP95, 2))ms" -ForegroundColor Green
            } else {
                Write-Host "  ERROR: Invalid timing values (must be > 0)" -ForegroundColor Red
            }
        } else {
            Write-Host "  ERROR: No timing data captured" -ForegroundColor Red
        }
    }
}

# HARD-FAIL checks
$enginesExecuted = $enginesExecuted | Select-Object -Unique
if ($enginesExecuted.Count -eq 0) {
    Write-Host ""
    Write-Host "HARD-FAIL: No engines actually executed successfully" -ForegroundColor Red
    exit 1
}

if ($rawLogsCreated.Count -eq 0) {
    Write-Host ""
    Write-Host "HARD-FAIL: No raw logs were created" -ForegroundColor Red
    exit 1
}

if ($allResults.Count -eq 0) {
    Write-Host ""
    Write-Host "HARD-FAIL: No valid results captured" -ForegroundColor Red
    exit 1
}

# Generate report
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GENERATING REPORT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$reportFile = "$BENCH_DIR\results\TIER_BP_$TIMESTAMP.md"
$gpuName = & nvidia-smi --query-gpu=name --format=csv,noheader 2>$null

$reportContent = @"
# Mind-Ray Tier BP (Persistent) Benchmark Results

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Tier**: BP (Persistent Mode)
**GPU**: $gpuName

---

## Methodology

**Tier BP measures persistent performance:**
- **COLD_START_MS**: Time from process start to first frame complete
- **STEADY_MS_PER_FRAME**: Median per-frame time after warmup
- **STEADY_P95_MS**: 95th percentile per-frame time after warmup

Both engines keep their runtime (CUDA context / Python+Mitsuba) alive across all frames.

---

## Configuration

| Parameter | Value |
|-----------|-------|
| Resolution | ${Width}x${Height} |
| SPP | $Spp |
| Bounces | $Bounces |
| Warmup Frames | $Warmup |
| Measure Frames | $($Frames - $Warmup) |
| Total Frames | $Frames |
| Runs | $Runs |
| Cooldown | ${CooldownSec}s |
| Scene | $Scene |

---

## Results (Median of $Runs runs)

| Engine | Spheres | Cold Start (ms) | Steady (ms/frame) | P95 (ms) | Steady Speedup |
|--------|---------|-----------------|-------------------|----------|----------------|
"@

# Group results by spheres for speedup calculation
$sphereGroups = $allResults | Group-Object -Property spheres

foreach ($group in $sphereGroups) {
    $sphereResults = $group.Group

    # Find Mitsuba steady time for speedup calculation
    $mitsubaResult = $sphereResults | Where-Object { $_.engine_name -eq "Mitsuba 3" } | Select-Object -First 1
    $mitsubaSteady = if ($mitsubaResult) { $mitsubaResult.steady_ms } else { 0 }

    foreach ($result in $sphereResults) {
        $speedup = if ($mitsubaSteady -gt 0 -and $result.steady_ms -gt 0) {
            [math]::Round($mitsubaSteady / $result.steady_ms, 2)
        } else {
            "N/A"
        }

        # Mitsuba is baseline (1.00x)
        if ($result.engine_name -eq "Mitsuba 3") {
            $speedup = "1.00x"
        } else {
            $speedup = "**${speedup}x**"
        }

        $reportContent += "`n| $($result.engine_name) | $($result.spheres) | $([math]::Round($result.cold_start_ms, 2)) | $([math]::Round($result.steady_ms, 2)) | $([math]::Round($result.steady_p95_ms, 2)) | $speedup |"
    }
}

$reportContent += @"


---

## Cold Start Comparison

| Engine | Spheres | Cold Start (ms) | Cold Start Speedup |
|--------|---------|-----------------|-------------------|
"@

foreach ($group in $sphereGroups) {
    $sphereResults = $group.Group
    $mitsubaResult = $sphereResults | Where-Object { $_.engine_name -eq "Mitsuba 3" } | Select-Object -First 1
    $mitsubaCold = if ($mitsubaResult) { $mitsubaResult.cold_start_ms } else { 0 }

    foreach ($result in $sphereResults) {
        $speedup = if ($mitsubaCold -gt 0 -and $result.cold_start_ms -gt 0) {
            [math]::Round($mitsubaCold / $result.cold_start_ms, 2)
        } else {
            "N/A"
        }

        if ($result.engine_name -eq "Mitsuba 3") {
            $speedup = "1.00x"
        } else {
            $speedup = "**${speedup}x**"
        }

        $reportContent += "`n| $($result.engine_name) | $($result.spheres) | $([math]::Round($result.cold_start_ms, 2)) | $speedup |"
    }
}

$reportContent += @"


---

## Verification Footer

| Check | Value |
|-------|-------|
| Engines Executed | $($enginesExecuted -join ', ') |
| Raw Logs Created | $($rawLogsCreated.Count) |
| Valid Results | $($allResults.Count) |
| Timestamp | $TIMESTAMP |

---

## Raw Data

- Logs: ``bench/results/raw/tier_bp/``
- Contract: ``bench/contract_v2.md``

---

## Notes

- **Tier BP** measures persistent mode (context/runtime kept alive)
- **Cold Start** includes: process launch, runtime init, scene build, first frame
- **Steady State** excludes: warmup frames, measures only measurement frames
- Do NOT compare with Tier A or Tier B numbers
"@

# Write without BOM
[System.IO.File]::WriteAllText($reportFile, $reportContent)

# Verify report was created
if (!(Test-Path $reportFile)) {
    Write-Host "HARD-FAIL: Report file was not created" -ForegroundColor Red
    exit 1
}

Write-Host "Report: $reportFile" -ForegroundColor Green

# Update LATEST_TIER_BP.md
$latestFile = "$BENCH_DIR\results\LATEST_TIER_BP.md"
Copy-Item $reportFile $latestFile -Force
Write-Host "Updated: $latestFile" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TIER BP BENCHMARK COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "  Engines: $($enginesExecuted -join ', ')"
Write-Host "  Logs: $($rawLogsCreated.Count) files"
Write-Host "  Results: $($allResults.Count) data points"

exit 0
