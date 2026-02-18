# Windows Update Repair - Custom Detection Script for Intune
# Version: 1.0.0
# Purpose: Check if Windows Update Repair script is installed and version is current

# Script version to detect
$ScriptVersion = "1.0.0"
$ScriptName = "Windows-Update-Repair"

# Check if script files exist in standard Intune deployment location
$ScriptPath = "$env:ProgramFiles\Siderise\IntuneScripts\$ScriptName"
$DetectionFile = "$ScriptPath\Detection.ps1"
$RemediationFile = "$ScriptPath\Remediation.ps1"

# Initialize detection result
$IsInstalled = $false
$VersionMatch = $false

Write-Host "Checking Windows Update Repair script installation..."

# Check if script directory exists
if (Test-Path $ScriptPath) {
    Write-Host "Script directory found: $ScriptPath"
    
    # Check if both script files exist
    if ((Test-Path $DetectionFile) -and (Test-Path $RemediationFile)) {
        Write-Host "Both script files found"
        $IsInstalled = $true
        
        # Check version in detection script
        try {
            $DetectionContent = Get-Content -Path $DetectionFile -Raw
            if ($DetectionContent -match "Version:\s*($ScriptVersion)") {
                Write-Host "Version match found: $ScriptVersion"
                $VersionMatch = $true
            } else {
                Write-Host "Version mismatch detected"
            }
        } catch {
            Write-Host "Error reading detection script version"
        }
        
        # Check version in remediation script
        try {
            $RemediationContent = Get-Content -Path $RemediationFile -Raw
            if ($RemediationContent -match "Version:\s*($ScriptVersion)") {
                Write-Host "Remediation script version confirmed: $ScriptVersion"
            } else {
                Write-Host "Remediation script version mismatch"
                $VersionMatch = $false
            }
        } catch {
            Write-Host "Error reading remediation script version"
            $VersionMatch = $false
        }
    } else {
        Write-Host "Script files not found"
        if (-not (Test-Path $DetectionFile)) {
            Write-Host "Missing: Detection.ps1"
        }
        if (-not (Test-Path $RemediationFile)) {
            Write-Host "Missing: Remediation.ps1"
        }
    }
} else {
    Write-Host "Script directory not found: $ScriptPath"
}

# Return detection result
if ($IsInstalled -and $VersionMatch) {
    Write-Host "Windows Update Repair script v$ScriptVersion is properly installed"
    Write-Host "Exit code: 0"
    exit 0
} else {
    Write-Host "Windows Update Repair script is not installed or version mismatch"
    if ($IsInstalled -and -not $VersionMatch) {
        Write-Host "Reason: Version mismatch - expected v$ScriptVersion"
    } elseif (-not $IsInstalled) {
        Write-Host "Reason: Script not installed"
    }
    Write-Host "Exit code: 1"
    exit 1
}
