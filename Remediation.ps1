# Windows Update Repair Remediation Script
# Version: 1.0.0
# Purpose: Repair Windows Update issues for E5 Proactive Remediation

# Write remediation log
Write-Host "Starting Windows Update remediation..."

# Step 1 - Restart services
Write-Host "Step 1: Restarting Windows Update related services..."

try {
    # Restart wuauserv service
    Write-Host "Restarting wuauserv service..."
    Restart-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    
    # Restart bits service
    Write-Host "Restarting bits service..."
    Restart-Service -Name "bits" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    
    # Restart cryptsvc service
    Write-Host "Restarting cryptsvc service..."
    Restart-Service -Name "cryptsvc" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    
    Write-Host "Service restart completed"
} catch {
    Write-Host "Warning: Error during service restart - $($_.Exception.Message)"
}

# Step 2 - Reset update components
Write-Host "Step 2: Resetting Windows Update components..."

try {
    # Stop services forcefully
    Write-Host "Stopping wuauserv service..."
    Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Write-Host "Stopping bits service..."
    Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 5
    
    # Rename SoftwareDistribution folder
    $softDistPath = "C:\Windows\SoftwareDistribution"
    if (Test-Path $softDistPath) {
        Write-Host "Renaming SoftwareDistribution folder..."
        Rename-Item -Path $softDistPath -NewName "SoftwareDistribution.old" -Force -ErrorAction SilentlyContinue
        Write-Host "SoftwareDistribution renamed to SoftwareDistribution.old"
    } else {
        Write-Host "SoftwareDistribution folder not found"
    }
    
    # Rename catroot2 folder
    $catroot2Path = "C:\Windows\System32\catroot2"
    if (Test-Path $catroot2Path) {
        Write-Host "Renaming catroot2 folder..."
        Rename-Item -Path $catroot2Path -NewName "catroot2.old" -Force -ErrorAction SilentlyContinue
        Write-Host "catroot2 renamed to catroot2.old"
    } else {
        Write-Host "catroot2 folder not found"
    }
    
    Start-Sleep -Seconds 3
    
    # Start services again
    Write-Host "Starting wuauserv service..."
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Write-Host "Starting bits service..."
    Start-Service -Name "bits" -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 5
    
    Write-Host "Update components reset completed"
} catch {
    Write-Host "Warning: Error during update components reset - $($_.Exception.Message)"
}

# Step 3 - Force scan
Write-Host "Step 3: Forcing Windows Update scan..."

try {
    # Start scan
    Write-Host "Starting Windows Update scan..."
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartScan" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    
    # Start download
    Write-Host "Starting Windows Update download..."
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartDownload" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    
    # Start install
    Write-Host "Starting Windows Update install..."
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartInstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    
    Write-Host "Windows Update scan and install process initiated"
} catch {
    Write-Host "Warning: Error during forced scan - $($_.Exception.Message)"
}

# Final verification
Write-Host "Remediation completed. Verifying service status..."

try {
    $wuauserv = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    $bits = Get-Service -Name "bits" -ErrorAction SilentlyContinue
    
    if ($wuauserv -and $wuauserv.Status -eq "Running") {
        Write-Host "✓ wuauserv service is running"
    } else {
        Write-Host "✗ wuauserv service status: $($wuauserv.Status)"
    }
    
    if ($bits -and $bits.Status -eq "Running") {
        Write-Host "✓ bits service is running"
    } else {
        Write-Host "✗ bits service status: $($bits.Status)"
    }
} catch {
    Write-Host "Could not verify final service status"
}

Write-Host "Windows Update remediation script completed"
Write-Host "Exit code: 0"
exit 0
