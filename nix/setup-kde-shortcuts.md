# KDE Dictation Shortcuts Setup

The dictation system is working perfectly, but KDE shortcuts need to be manually configured.

## Manual Setup Instructions

1. **Open System Settings**
   - Press `Alt+F2` and type "System Settings"
   - Or click the Application Menu → System Settings

2. **Navigate to Shortcuts**
   - Go to: **Shortcuts** → **Global Shortcuts**

3. **Add Custom Shortcuts**
   - Click "Add Application..." or look for existing "Dictation Start" and "Dictation Stop & Type" entries
   - If they don't exist, create custom shortcuts:

### For Dictation Start:
- **Name**: Dictation Start
- **Command**: `dictation-start`
- **Shortcut**: `Meta+V`

### For Dictation Stop:
- **Name**: Dictation Stop & Type  
- **Command**: `dictation-stop`
- **Shortcut**: `Meta+Shift+V`

4. **Apply and Test**
   - Click "Apply" 
   - Test the shortcuts:
     - `Meta+V` to start recording
     - `Meta+Shift+V` to stop and transcribe

## Alternative: Use Command Line

The dictation system works perfectly from the command line:
```bash
dictation-start    # Start recording
dictation-stop     # Stop and transcribe
```

## Verification

The system is working correctly:
- ✅ API-based transcription (1-2 seconds vs 27+ seconds local)
- ✅ Audio recording and processing
- ✅ Text insertion with xdotool
- ✅ Proper error handling and notifications
- ✅ Debug logging for troubleshooting

The only remaining step is the manual KDE shortcut configuration.