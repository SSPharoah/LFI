# LFI

**Leica Fotografie International Image Converter**

A simple macOS app that converts any image to JPG format optimized for LFI submission requirements (under 15MB).

## Features

- Drag & drop or click to select any image format
- Automatically converts to highest quality JPG under 15MB
- Uses quality reduction first (preserves resolution)
- Falls back to resolution scaling only if necessary
- Dark UI inspired by Leica aesthetics

## Algorithm

1. Start with 95% JPEG quality at original resolution
2. Binary search quality down to 70% minimum to fit under 15MB
3. If still over limit, reduce canvas by 10% and repeat
4. Output the highest quality result under 15MB

## Requirements

- macOS 14.0+
- Xcode 15+

## Building

```bash
open LFI.xcodeproj
```

Build and run in Xcode (Cmd+R).

## Usage

1. Launch the app
2. Drop an image onto the window (or click to select)
3. Wait for processing
4. Click "Save JPG" to export

## License

MIT
