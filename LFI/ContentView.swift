import SwiftUI
import UniformTypeIdentifiers

// MARK: - Typography (EASILY REPLACEABLE)
// To use a custom font:
// 1. Add your .ttf or .otf file to the project
// 2. Add it to Info.plist under "Fonts provided by application"
// 3. Change this constant to your font's PostScript name
//
// Suggested Leica-like fonts (free, redistributable):
// - "Inter" (https://rsms.me/inter/) - clean, geometric
// - "IBMPlexSans" (https://github.com/IBM/plex) - German industrial
// - "SourceSansPro" (https://github.com/adobe-fonts/source-sans) - neutral
//
// Set to nil to use system font (SF Pro)
private let CUSTOM_FONT_NAME: String? = "Inter"

// MARK: - Design System

private enum LFIColors {
    static let background = Color(red: 0.08, green: 0.08, blue: 0.08)
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.11)
    static let surfaceHover = Color(red: 0.14, green: 0.12, blue: 0.12)

    // Cream/off-white: white with warmth
    static let textPrimary = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let textSecondary = Color(red: 0.60, green: 0.58, blue: 0.54)
    static let textTertiary = Color(red: 0.40, green: 0.38, blue: 0.36)

    // Leica red - used sparingly
    static let accent = Color(red: 0.87, green: 0.12, blue: 0.15)
    static let accentSubtle = Color(red: 0.87, green: 0.12, blue: 0.15).opacity(0.8)
}

private enum LFITypography {
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let fontName = CUSTOM_FONT_NAME {
            // Map weight to font variant naming convention
            let weightSuffix: String
            switch weight {
            case .ultraLight: weightSuffix = "-UltraLight"
            case .thin: weightSuffix = "-Thin"
            case .light: weightSuffix = "-Light"
            case .regular: weightSuffix = "-Regular"
            case .medium: weightSuffix = "-Medium"
            case .semibold: weightSuffix = "-SemiBold"
            case .bold: weightSuffix = "-Bold"
            case .heavy: weightSuffix = "-Heavy"
            case .black: weightSuffix = "-Black"
            default: weightSuffix = "-Regular"
            }

            // Try weight-specific variant first, fall back to base font
            if let _ = NSFont(name: fontName + weightSuffix, size: size) {
                return .custom(fontName + weightSuffix, size: size)
            }
            return .custom(fontName, size: size)
        }
        return .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Main View

struct ContentView: View {
    @State private var isDragging = false
    @State private var isProcessing = false
    @State private var statusMessage = ""
    @State private var originalInfo = ""
    @State private var outputInfo = ""
    @State private var processedImage: NSImage?
    @State private var processedData: Data?
    @State private var outputFilename = "output_LFI.jpg"

    private let maxSize = 15 * 1024 * 1024
    private let minQuality: CGFloat = 0.70
    private let startQuality: CGFloat = 0.95
    private let scaleStep: CGFloat = 0.90

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)

            // Header
            VStack(spacing: 6) {
                Text("LFI")
                    .font(LFITypography.font(size: 32, weight: .light))
                    .tracking(12)
                    .foregroundColor(LFIColors.textPrimary)

                Text("LEICA FOTOGRAFIE INTERNATIONAL")
                    .font(LFITypography.font(size: 9, weight: .medium))
                    .tracking(3)
                    .foregroundColor(LFIColors.textTertiary)
            }

            Spacer().frame(height: 36)

            // Drop Zone
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(
                        isDragging ? LFIColors.accent : LFIColors.accent.opacity(0.4),
                        lineWidth: 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isDragging ? LFIColors.surfaceHover : LFIColors.surface)
                    )

                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: LFIColors.textSecondary))
                } else {
                    VStack(spacing: 12) {
                        // Minimal icon - just a rectangle suggesting an image
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(LFIColors.textTertiary.opacity(0.4), lineWidth: 1)
                            .frame(width: 32, height: 24)

                        Text("Drop image")
                            .font(LFITypography.font(size: 13, weight: .regular))
                            .foregroundColor(LFIColors.textSecondary)
                    }
                }
            }
            .frame(height: 160)
            .padding(.horizontal, 40)
            .onDrop(of: [.image, .fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
                return true
            }
            .onTapGesture { selectFile() }

            Spacer().frame(height: 28)

            // Status
            VStack(spacing: 10) {
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(LFITypography.font(size: 11, weight: .regular))
                        .foregroundColor(statusMessage.contains("Ready") ? LFIColors.textPrimary : LFIColors.textSecondary)
                }

                if !originalInfo.isEmpty {
                    VStack(spacing: 4) {
                        Text(originalInfo)
                            .font(LFITypography.font(size: 10, weight: .regular))
                            .foregroundColor(LFIColors.textTertiary)
                        Text(outputInfo)
                            .font(LFITypography.font(size: 10, weight: .regular))
                            .foregroundColor(LFIColors.textSecondary)
                    }
                }
            }
            .frame(height: 60)

            // Preview
            if let image = processedImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 180)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Save Button - the only splash of red
            if processedData != nil {
                Button(action: saveFile) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(LFIColors.accent)
                            .frame(width: 6, height: 6)
                        Text("Save")
                            .font(LFITypography.font(size: 12, weight: .medium))
                            .tracking(1)
                            .foregroundColor(LFIColors.textPrimary)
                    }
                    .frame(width: 100, height: 36)
                    .background(LFIColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(LFIColors.textTertiary.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }

            // Footer
            Text("15 MB")
                .font(LFITypography.font(size: 9, weight: .regular))
                .tracking(2)
                .foregroundColor(LFIColors.textTertiary.opacity(0.5))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LFIColors.background)
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            processImage(url: url)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async { processImage(url: url) }
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    DispatchQueue.main.async { processImage(url: url) }
                }
            }
        }
    }

    private func processImage(url: URL) {
        guard let image = NSImage(contentsOf: url) else {
            statusMessage = "Failed to load"
            return
        }

        isProcessing = true
        statusMessage = "Processing"
        processedImage = nil
        processedData = nil

        let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        let filename = url.deletingPathExtension().lastPathComponent
        outputFilename = "\(filename)_LFI.jpg"

        guard let originalRep = image.representations.first else {
            statusMessage = "Failed"
            isProcessing = false
            return
        }
        let originalWidth = originalRep.pixelsWide
        let originalHeight = originalRep.pixelsHigh

        originalInfo = "Input: \(formatSize(originalSize)) · \(originalWidth)×\(originalHeight)"

        DispatchQueue.global(qos: .userInitiated).async {
            let result = findOptimalOutput(image: image, originalWidth: originalWidth, originalHeight: originalHeight)

            DispatchQueue.main.async {
                isProcessing = false

                if let data = result.data {
                    processedData = data
                    processedImage = NSImage(data: data)
                    statusMessage = "Ready"
                    outputInfo = "Output: \(formatSize(data.count)) · \(result.width)×\(result.height) · Q\(Int(result.quality * 100))"
                } else {
                    statusMessage = "Failed"
                }
            }
        }
    }

    private func findOptimalOutput(image: NSImage, originalWidth: Int, originalHeight: Int) -> (data: Data?, width: Int, height: Int, quality: CGFloat) {
        var scale: CGFloat = 1.0

        while scale >= 0.1 {
            let width = Int(CGFloat(originalWidth) * scale)
            let height = Int(CGFloat(originalHeight) * scale)

            var lo = minQuality
            var hi = startQuality
            var bestData: Data?
            var bestQuality = lo

            if let data = renderJPG(image: image, width: width, height: height, quality: hi), data.count <= maxSize {
                return (data, width, height, hi)
            }

            if let data = renderJPG(image: image, width: width, height: height, quality: lo) {
                if data.count <= maxSize {
                    bestData = data
                    bestQuality = lo
                } else {
                    scale *= scaleStep
                    continue
                }
            }

            for _ in 0..<10 {
                let mid = (lo + hi) / 2
                if let data = renderJPG(image: image, width: width, height: height, quality: mid) {
                    if data.count <= maxSize {
                        bestData = data
                        bestQuality = mid
                        lo = mid
                    } else {
                        hi = mid
                    }
                }
            }

            if let data = bestData {
                return (data, width, height, bestQuality)
            }

            scale *= scaleStep
        }

        let width = Int(CGFloat(originalWidth) * 0.1)
        let height = Int(CGFloat(originalHeight) * 0.1)
        let data = renderJPG(image: image, width: width, height: height, quality: minQuality)
        return (data, width, height, minQuality)
    }

    private func renderJPG(image: NSImage, width: Int, height: Int, quality: CGFloat) -> Data? {
        // Get CGImage from source - handles all color spaces including Monochrom
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        // Create RGB bitmap context (JPEG output is always RGB)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        // High quality interpolation
        context.interpolationQuality = .high

        // Draw source image scaled to target size
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get the rendered image
        guard let outputCGImage = context.makeImage() else {
            return nil
        }

        // Convert to JPEG data
        let bitmap = NSBitmapImageRep(cgImage: outputCGImage)
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality])
    }

    private func saveFile() {
        guard let data = processedData else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.jpeg]
        panel.nameFieldStringValue = outputFilename

        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url)
        }
    }

    private func formatSize(_ bytes: Int) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
        return String(format: "%.2f MB", Double(bytes) / (1024 * 1024))
    }
}

#Preview {
    ContentView()
}
