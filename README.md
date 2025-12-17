# LFI

**Leica Fotografie International Image Converter**

---

Hello.

I'm Eric Bigelow, a software engineer from Florida.

I'm usually paid for my work, but this one didn't feel the same as commercial. It's really simple. I went from non-existent to finished product, uploading to GitHub in 12 minutes flat. My fastest work. I'm not in competition with you, and I can make things that aren't this… mono-purposed, but this app does what I need it to do, and it does it quickly and gracefully, and serves no other purpose.

All this app does is take an image file, then applies sorcery to ensure it still looks its best while simultaneously also removing any disqualifying elements that would render it ineligible for submission to the LFI Mastershot Selection process, or the LFI Challenge submissions process. If you are ever selected, they'll contact you in attempt to get your original or post-edit RAW file anyway. These are the "thumbnails". If LFI ever asks you, specifically, to send them an image—please do not run it through this app.

I honestly got physically tired, having to shift gears from Lightroom, final tweaks, color grading, and all the intensely creative adjustments you need to make while in hard-art mode, only to have to switch to the dumb handles of making a JPG "fit" inside someone's idea of acceptable parameters. This app is an overly simple file converter, but I see it as a singularly purposed shield that prevents you from needing to leave creative mode to pay attention to dumb things, therefore possibly losing your flow. Having "The Hot Hand" is rare enough as it is these days. At least it is for me.

If you don't own a Leica, this app is almost certainly useless to you.

If you DO own a Leica, first of all congratulations! I hope it serves you, and all the future generations who use it, equally well.

Will you be using your Leica to submit photos to the LFI Mastershot or LFI Challenge programs?

If not, this app is almost certainly useless to you, too.

If you plan to submit photos to either of these programs, and the photos were taken with any Leica camera, this app might actually be useful to you. If that's you, this is my formal wish that it serves you well throughout your journey with Leica photography. It's not like any other, and it deserves its own tool, no matter how simple.

Thanks for your time.

**Eric Bigelow**

---

## Installation

### Build from Source

Requires macOS 14.0+ and Xcode 15+.

```bash
git clone https://github.com/SSPharoah/LFI.git
cd LFI
open LFI.xcodeproj
# Press Cmd+R to build and run
```

## Usage

1. Launch the app
2. Drag an image onto the window (or click to select)
3. Wait for processing
4. Click **Save**
5. Submit to LFI

## How It Works

1. Accepts any image format (RAW, TIFF, PNG, HEIC, JPG, etc.)
2. Converts to JPG at 95% quality
3. If over 15MB, reduces quality incrementally (minimum 70%)
4. If still over 15MB at 70%, scales resolution down 10% and repeats
5. Outputs the highest quality JPG under 15MB possible

## License

**MIT License** — Copyright (c) 2025 Agency Instruments

Free to use, modify, and distribute. Just keep the copyright notice.

See [LICENSE](LICENSE) for the full text.

## Disclaimer

This app is not affiliated with, endorsed by, or connected to Leica Camera AG or LFI Magazine. "Leica" and "LFI" are trademarks of Leica Camera AG.
