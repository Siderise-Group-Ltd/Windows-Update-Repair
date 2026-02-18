# Windows Update Repair Detection Script
# Version: 1.0.0
# Purpose: Detect Windows Update issues for E5 Proactive Remediation

# Initialize variables
$unhealthy = $false
$issues = @()

# Write detection log
Write-Host "Starting Windows Update health detection..."

# Check 1: Pending reboot flags
try {
    $rebootPending1 = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
    $rebootPending2 = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue
    
    if ($rebootPending1 -or $rebootPending2) {
        $unhealthy = $true
        $issues += "Pending reboot detected"
        Write-Host "Issue found: Pending reboot flags detected"
    }
} catch {
    Write-Host "Warning: Could not check pending reboot flags"
}

# Check 2: Windows Update service status
try {
    $wuauserv = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    
    if (-not $wuauserv) {
        $unhealthy = $true
        $issues += "Windows Update service not found"
        Write-Host "Issue found: Windows Update service not found"
    } elseif ($wuauserv.Status -ne "Running") {
        $unhealthy = $true
        $issues += "Windows Update service not running (Status: $($wuauserv.Status))"
        Write-Host "Issue found: Windows Update service not running"
    } else {
        Write-Host "Windows Update service is running"
    }
} catch {
    $unhealthy = $true
    $issues += "Failed to check Windows Update service"
    Write-Host "Issue found: Failed to check Windows Update service - $($_.Exception.Message)"
}

# Check 3: Last installed update (if > 30 days ago)
try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $history = $searcher.QueryHistory(0, 1)
    
    if ($history.Count -gt 0) {
        $lastUpdate = $history[0]
        $daysSinceLastUpdate = (Get-Date) - $lastUpdate.Date
        
        if ($daysSinceLastUpdate.Days -gt 30) {
            $unhealthy = $true
            $issues += "Last update was $($daysSinceLastUpdate.Days) days ago"
            Write-Host "Issue found: Last update was $($daysSinceLastUpdate.Days) days ago"
        } else {
            Write-Host "Last update was $($daysSinceLastUpdate.Days) days ago"
        }
    } else {
        $unhealthy = $true
        $issues += "No update history found"
        Write-Host "Issue found: No update history found"
    }
} catch {
    Write-Host "Warning: Could not check update history - $($_.Exception.Message)"
}

# Check 4: Update errors in event log (optional advanced check)
try {
    $errorEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-WindowsUpdateClient'
        Level = 2  # Error level
        StartTime = (Get-Date).AddDays(-7)
    } -ErrorAction SilentlyContinue | Where-Object { $_.Id -in @(20, 25, 31) }
    
    if ($errorEvents.Count -gt 0) {
        $unhealthy = $true
        $issues += "Found $($errorEvents.Count) Windows Update error events in last 7 days"
        Write-Host "Issue found: Found $($errorEvents.Count) Windows Update error events"
    }
} catch {
    Write-Host "Warning: Could not check event log for errors"
}

# Output results
if ($unhealthy) {
    Write-Host "Windows Update is UNHEALTHY"
    Write-Host "Issues detected: $($issues -join ', ')"
    Write-Host "Exit code: 1"
    exit 1
} else {
    Write-Host "Windows Update is HEALTHY"
    Write-Host "Exit code: 0"
    exit 0
}
