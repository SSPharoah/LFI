# LFI

**Leica Fotografie International Image Converter**

## Why This Exists

I shoot with a Leica. I wanted to submit photos to [LFI](https://lfi-online.de/) (Leica Fotografie International), the official Leica magazine and gallery. I kept getting rejected.

Not because the photos were bad. Because of *technical requirements*.

LFI has strict submission guidelines:
- **Format:** JPG only
- **Maximum file size:** 15 MB
- **Minimum file size:** exists (I forget the exact number, but it's not a concern for Leica shooters)
- Various other constraints around dimensions and quality

My workflow produces large RAW files. I export to TIFF or high-quality JPG. The files are too big. I compress. Now they're too small, or the quality is visibly degraded. I resize. Now the aspect ratio is wrong, or the dimensions trigger some other rule. Back and forth. Rejected. Rejected. Rejected.

This app eliminates the guesswork.

**Drop any image. Get a JPG that LFI will accept.**

That's it. That's the entire purpose. One input, one output, zero rejections.

## What It Does

1. Accepts any image format (RAW, TIFF, PNG, HEIC, JPG, whatever)
2. Converts to JPG
3. Starts at highest possible quality (95%)
4. If file exceeds 15 MB, reduces quality incrementally (down to 70% minimum)
5. If still too large at 70% quality, reduces resolution by 10% and tries again
6. Outputs the highest quality JPG under 15 MB that it can produce

The algorithm prioritizes quality over resolution. A slightly smaller image at high quality looks better than a full-resolution image with compression artifacts. This matters for Leica glass.

## Design Philosophy

The interface is deliberately minimal. Dark charcoal background. Cream-colored text. A single red dot—the only color—because if you know, you know.

This app could have been made by Leica. It wasn't. But it could have been.

## Installation

### Build from Source

Requires macOS 14.0+ and Xcode 15+.

```bash
git clone https://github.com/yourusername/LFI.git
cd LFI
open LFI.xcodeproj
# Press Cmd+R to build and run
```

### Pre-built Release

Check the [Releases](https://github.com/yourusername/LFI/releases) page for a signed `.app` bundle.

## Usage

1. Launch the app
2. Drag an image onto the window (or click to select from Finder)
3. Wait for processing (usually 1-3 seconds)
4. Click **Save**
5. Submit to LFI

## Customizing the Font

The app uses the system font (SF Pro) by default. If you want a more Leica-appropriate typeface:

1. Download a font:
   - [Inter](https://rsms.me/inter/) — clean, geometric (OFL license)
   - [IBM Plex Sans](https://github.com/IBM/plex) — German industrial aesthetic (OFL license)
   - [Source Sans Pro](https://github.com/adobe-fonts/source-sans) — neutral, professional (OFL license)

2. Add the `.ttf` or `.otf` files to the Xcode project

3. Add to `Info.plist`:
   ```xml
   <key>ATSApplicationFontsPath</key>
   <string>Fonts</string>
   ```

4. Edit `ContentView.swift` line 16:
   ```swift
   private let CUSTOM_FONT_NAME: String? = "Inter"  // or your font's PostScript name
   ```

## Technical Details

- **Language:** Swift / SwiftUI
- **Platform:** macOS 14.0+
- **Dependencies:** None (uses native frameworks only)
- **Image processing:** `NSBitmapImageRep` with Lanczos resampling

## License

**CC0 1.0 Universal (Public Domain)**

This software is released into the public domain. You can copy, modify, distribute, and use it for any purpose, commercial or non-commercial, without asking permission and without attribution.

See [LICENSE](LICENSE) for the full legal text.

## Disclaimer

This app is not affiliated with, endorsed by, or connected to Leica Camera AG or LFI Magazine. "Leica" and "LFI" are trademarks of Leica Camera AG. This is an independent utility created by a frustrated photographer who wanted to submit photos without fighting file format requirements.

---

*For Leica shooters, by a Leica shooter.*
