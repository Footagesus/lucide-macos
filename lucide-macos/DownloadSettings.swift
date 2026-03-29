//
//  DownloadSettings.swift
//  lucide-macos
//
//  Created by oftgs on 28.03.2026.
//


import SwiftUI
import AppKit
import UniformTypeIdentifiers

@Observable
final class DownloadSettings {
    var size: CGFloat = 512 {
        didSet { save() }
    }
    var color: Color = .black {
        didSet { save() }
    }
    var weight: Double = 2 {
        didSet { save() }
    }
    var absoluteWeight: Bool = false {
        didSet { save() }
    }

    static let shared = DownloadSettings()

    private init() {
        size = CGFloat(UserDefaults.standard.double(forKey: "dl_size").nonZero ?? 512)
        weight = UserDefaults.standard.double(forKey: "dl_weight").nonZero ?? 2
        absoluteWeight = UserDefaults.standard.bool(forKey: "dl_absoluteWeight")
        if let hex = UserDefaults.standard.string(forKey: "dl_color") {
            color = Color(hex: hex) ?? .black
        }
    }

    func save() {
        UserDefaults.standard.set(Double(size), forKey: "dl_size")
        UserDefaults.standard.set(weight, forKey: "dl_weight")
        UserDefaults.standard.set(absoluteWeight, forKey: "dl_absoluteWeight")
        UserDefaults.standard.set(color.toHex() ?? "#000000", forKey: "dl_color")
    }

    func reset() {
        size = 512
        color = .black
        weight = 2
        absoluteWeight = false
    }
}

private extension Double {
    var nonZero: Double? { self == 0 ? nil : self }
}

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        self.init(
            red: Double((val >> 16) & 0xFF) / 255,
            green: Double((val >> 8) & 0xFF) / 255,
            blue: Double(val & 0xFF) / 255
        )
    }
}


struct IconExporter {
    static func svgString(icon: LucideIcon, settings: DownloadSettings) -> String? {
        guard let url = icon.svgURL,
              let data = try? Data(contentsOf: url),
              var svg = String(data: data, encoding: .utf8) else { return nil }

        let hex = settings.color.toHex() ?? "#000000"
        let strokeWidth = String(format: "%.1f", settings.weight)

        svg = svg.replacingOccurrences(of: #"stroke="[^"]*""#, with: "stroke=\"\(hex)\"", options: .regularExpression)
        svg = svg.replacingOccurrences(of: #"stroke-width="[^"]*""#, with: "stroke-width=\"\(strokeWidth)\"", options: .regularExpression)

        return svg
    }

    static func downloadSVG(icon: LucideIcon, settings: DownloadSettings) {
        guard let svg = svgString(icon: icon, settings: settings) else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(icon.name).svg"
        panel.allowedContentTypes = [.svg]
        if panel.runModal() == .OK, let url = panel.url {
            try? svg.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    static func downloadPNG(icon: LucideIcon, settings: DownloadSettings) {
        guard let svg = svgString(icon: icon, settings: settings),
              let data = svg.data(using: .utf8) else { return }

        let size = NSSize(width: settings.size, height: settings.size)
        guard let image = NSImage(data: data) else { return }
        image.size = size

        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        image.draw(in: NSRect(origin: .zero, size: size))
        NSGraphicsContext.restoreGraphicsState()

        guard let pngData = rep.representation(using: .png, properties: [:]) else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(icon.name).png"
        panel.allowedContentTypes = [.png]
        if panel.runModal() == .OK, let url = panel.url {
            try? pngData.write(to: url)
        }
    }
}
