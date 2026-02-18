# Windows Update Repair - E5 Proactive Remediation Script

## Overview
This E5 proactive remediation script automatically detects and repairs Windows Update issues on devices that are stuck in failed or pending states.

## Version
**1.0.0** (Major.Minor.Bugfix)

## Files Created

### Detection Script (`Detection.ps1`)
- **Purpose**: Detects Windows Update health issues
- **Checks Performed**:
  - Pending reboot flags in registry
  - Windows Update service status
  - Last installed update (if > 30 days ago)
  - Update errors in event log (Event IDs 20, 25, 31)
- **Exit Codes**: 0 (healthy), 1 (unhealthy)

### Remediation Script (`Remediation.ps1`)
- **Purpose**: Repairs detected Windows Update issues
- **Steps Performed**:
  1. **Restart Services**: wuauserv, bits, cryptsvc
  2. **Reset Update Components**:
     - Stop wuauserv and bits services
     - Rename SoftwareDistribution to SoftwareDistribution.old
     - Rename catroot2 to catroot2.old
     - Restart wuauserv and bits services
  3. **Force Update Scan**:
     - UsoClient StartScan
     - UsoClient StartDownload
     - UsoClient StartInstall

### Custom Detection Script (`CustomDetection.ps1`)
- **Purpose**: Intune app detection for version checking
- **Checks**: Script installation and version matching
- **Exit Codes**: 0 (installed), 1 (not installed/version mismatch)

## Deployment Package

### Output Folder Contents
- `Remediation.intunewin` - Packaged remediation script for Intune deployment
- `CustomDetection.ps1` - Custom detection script for Intune app

## Intune Deployment Instructions

### For E5 Proactive Remediation:
1. Upload `Detection.ps1` as the detection script
2. Upload `Remediation.ps1` as the remediation script
3. Set schedule to run daily or as needed

### For Intune App Deployment:
1. Use `Remediation.intunewin` as the application file
2. Use `CustomDetection.ps1` as the detection rule
3. Deploy to target device groups

## Brand Compliance
- Follows Siderise brand guidelines
- Uses approved color scheme and typography
- Maintains professional, technical tone

## Safety Features
- Error handling with try-catch blocks
- Graceful fallbacks for non-critical operations
- Service status verification after remediation
- Detailed logging for troubleshooting

## Notes
- Scripts require administrative privileges
- Remediation may trigger system restart
- Old SoftwareDistribution and catroot2 folders are preserved with .old extension
- Event log checking is optional and won't fail detection if inaccessible
