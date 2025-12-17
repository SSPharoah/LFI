# LFI

**Leica Fotografie International Image Converter**

A minimalist macOS utility that converts any image to JPG format optimized for LFI submission (under 15MB).

## Design

German industrial austerity. Dark charcoal. Cream text. A single red dot.

## Features

- Drag & drop or click to select
- Any input format → JPG under 15MB
- Quality-first algorithm preserves resolution
- One font constant to customize typography

## Fonts

The app uses system font by default. To use a custom Leica-like font:

1. Download a font (suggestions below)
2. Add the `.ttf` or `.otf` to the Xcode project
3. Add to `Info.plist` under "Fonts provided by application"
4. Set `CUSTOM_FONT_NAME` in `ContentView.swift` line 16

**Suggested fonts (free, redistributable):**

| Font | License | Link |
|------|---------|------|
| Inter | OFL | [rsms.me/inter](https://rsms.me/inter/) |
| IBM Plex Sans | OFL | [github.com/IBM/plex](https://github.com/IBM/plex) |
| Source Sans Pro | OFL | [github.com/adobe-fonts/source-sans](https://github.com/adobe-fonts/source-sans) |

## Algorithm

1. Load image at original resolution
2. Binary search JPEG quality (95% → 70%) to fit under 15MB
3. If still over limit at 70%, scale down 10% and repeat
4. Output highest quality result under 15MB

## Requirements

- macOS 14.0+
- Xcode 15+

## Build

```bash
open LFI.xcodeproj
# Cmd+R to build and run
```

## License

MIT — Free to use, modify, and redistribute.
