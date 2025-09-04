# Container Startup Fix - apt_pkg Module Error

## Issue Summary
**Error ID**: ERR-2025-09-02-001
**Status**: ✅ Fixed
**Severity**: P1 (Major functionality broken)
**Date**: 2025-09-02 17:15

## Problem Description
Container startup was failing at step 2/9 during Python 3.11 installation with the following error:

```
ModuleNotFoundError: No module named 'apt_pkg'
Traceback (most recent call last):
  File "/usr/bin/add-apt-repository", line 5, in <module>
    import apt_pkg
```

## Root Cause Analysis
The minimal CUDA base image (`nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04`) does not include the `software-properties-common` package by default, which provides the `apt_pkg` module required by `add-apt-repository` command.

The startup script was attempting to add the deadsnakes PPA without first ensuring the prerequisite packages were installed.

## Solution Implemented
Modified `scripts/startup.sh` in the `install_python()` function:

**Before (problematic code)**:
```bash
install_python() {
    show_progress 2 9 "Installing Python 3.11 via deadsnakes PPA"
    
    # Add deadsnakes PPA
    add-apt-repository -y ppa:deadsnakes/ppa  # This fails!
    apt-get update -qq
    ...
}
```

**After (fixed code)**:
```bash
install_python() {
    show_progress 2 9 "Installing Python 3.11 via deadsnakes PPA"
    
    # Install software-properties-common first to fix apt_pkg issue
    apt-get update -qq
    apt-get install -y -qq software-properties-common
    
    # Add deadsnakes PPA
    add-apt-repository -y ppa:deadsnakes/ppa
    apt-get update -qq
    ...
}
```

## Technical Details
- **File Modified**: `/opt/docker/OmniTry/scripts/startup.sh`
- **Function**: `install_python()`
- **Lines**: 107-109 (added dependency installation)
- **Fix Type**: Proactive dependency installation

## Documentation Updates
1. **TROUBLESHOOTING.md**: Added new section documenting the error and fix
2. **JOURNAL.md**: Added error tracking entry with ERR-2025-09-02-001 tag
3. **Version**: Marked as fixed in v1.1.0

## Testing Status
- **Fix Applied**: ✅ Yes
- **Committed**: ✅ Yes (commit d4be478)
- **Pushed**: ✅ Yes
- **Ready for Testing**: ✅ Yes

## Prevention Measures
The fix is now part of the standard startup script, so all future container builds will automatically include this dependency resolution.

## Impact Assessment
- **User Impact**: High - Container completely failed to start
- **Fix Complexity**: Low - Simple dependency addition
- **Risk**: Low - Adding standard system package
- **Rollback**: Easy - revert commit if issues arise

## Related Files
- `scripts/startup.sh` (main fix)
- `TROUBLESHOOTING.md` (documentation)
- `JOURNAL.md` (error tracking)
- `.github/workflows/docker-build.yml` (automated builds will include fix)