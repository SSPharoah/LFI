import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isDragging = false
    @State private var isProcessing = false
    @State private var statusMessage = ""
    @State private var originalInfo = ""
    @State private var outputInfo = ""
    @State private var processedImage: NSImage?
    @State private var processedData: Data?
    @State private var outputFilename = "output_LFI.jpg"

    private let maxSize = 15 * 1024 * 1024 // 15MB
    private let minQuality: CGFloat = 0.70
    private let startQuality: CGFloat = 0.95
    private let scaleStep: CGFloat = 0.90

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text("LFI")
                    .font(.system(size: 36, weight: .light))
                    .tracking(8)
                    .foregroundColor(.white)
                Text("Leica Fotografie International")
                    .font(.system(size: 11, weight: .regular))
                    .tracking(2)
                    .foregroundColor(.gray)
            }
            .padding(.top, 30)
            .padding(.bottom, 25)

            // Drop Zone
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isDragging ? Color.red.opacity(0.8) : Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, dash: [8])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isDragging ? Color.red.opacity(0.05) : Color.white.opacity(0.02))
                    )

                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40, weight: .thin))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("Drop image here")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                        Text("or click to select")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 180)
            .padding(.horizontal, 30)
            .onDrop(of: [.image, .fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
                return true
            }
            .onTapGesture {
                selectFile()
            }

            // Status
            VStack(spacing: 12) {
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.system(size: 13))
                        .foregroundColor(statusMessage.contains("Ready") ? .green.opacity(0.8) : .orange.opacity(0.8))
                }

                if !originalInfo.isEmpty {
                    VStack(spacing: 4) {
                        Text(originalInfo)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.7))
                        Text(outputInfo)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.9))
                    }
                }
            }
            .frame(height: 80)
            .padding(.top, 20)

            // Preview
            if let image = processedImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
                    .padding(.horizontal, 30)
            }

            Spacer()

            // Download Button
            if processedData != nil {
                Button(action: saveFile) {
                    Text("Save JPG")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 44)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }

            // Footer
            Text("Target: JPG under 15MB")
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.4))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.1))
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
                    DispatchQueue.main.async {
                        processImage(url: url)
                    }
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    DispatchQueue.main.async {
                        processImage(url: url)
                    }
                }
            }
        }
    }

    private func processImage(url: URL) {
        guard let image = NSImage(contentsOf: url) else {
            statusMessage = "Failed to load image"
            return
        }

        isProcessing = true
        statusMessage = "Processing..."
        processedImage = nil
        processedData = nil

        let originalSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        let filename = url.deletingPathExtension().lastPathComponent
        outputFilename = "\(filename)_LFI.jpg"

        guard let originalRep = image.representations.first else {
            statusMessage = "Failed to read image"
            isProcessing = false
            return
        }
        let originalWidth = originalRep.pixelsWide
        let originalHeight = originalRep.pixelsHigh

        originalInfo = "Original: \(formatSize(originalSize)) (\(originalWidth) x \(originalHeight))"

        DispatchQueue.global(qos: .userInitiated).async {
            let result = findOptimalOutput(image: image, originalWidth: originalWidth, originalHeight: originalHeight)

            DispatchQueue.main.async {
                isProcessing = false

                if let data = result.data {
                    processedData = data
                    processedImage = NSImage(data: data)
                    statusMessage = "Ready to save"
                    outputInfo = "Output: \(formatSize(data.count)) (\(result.width) x \(result.height)) Q:\(Int(result.quality * 100))%"
                } else {
                    statusMessage = "Processing failed"
                }
            }
        }
    }

    private func findOptimalOutput(image: NSImage, originalWidth: Int, originalHeight: Int) -> (data: Data?, width: Int, height: Int, quality: CGFloat) {
        var scale: CGFloat = 1.0

        while scale >= 0.1 {
            let width = Int(CGFloat(originalWidth) * scale)
            let height = Int(CGFloat(originalHeight) * scale)

            // Binary search for best quality at this scale
            var lo = minQuality
            var hi = startQuality
            var bestData: Data?
            var bestQuality = lo

            // Check if max quality fits
            if let data = renderJPG(image: image, width: width, height: height, quality: hi), data.count <= maxSize {
                return (data, width, height, hi)
            }

            // Check if min quality fits
            if let data = renderJPG(image: image, width: width, height: height, quality: lo) {
                if data.count <= maxSize {
                    bestData = data
                    bestQuality = lo
                } else {
                    // Even min quality too big at this scale, reduce scale
                    scale *= scaleStep
                    continue
                }
            }

            // Binary search
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

        // Fallback
        let width = Int(CGFloat(originalWidth) * 0.1)
        let height = Int(CGFloat(originalHeight) * 0.1)
        let data = renderJPG(image: image, width: width, height: height, quality: minQuality)
        return (data, width, height, minQuality)
    }

    private func renderJPG(image: NSImage, width: Int, height: Int, quality: CGFloat) -> Data? {
        let newSize = NSSize(width: width, height: height)
        let newImage = NSImage(size: newSize)

        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()

        guard let tiffData = newImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

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
